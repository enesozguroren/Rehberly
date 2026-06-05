import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../profile/data/profile_repository.dart';
import '../data/create_route_request.dart';
import '../data/route_comment.dart';
import '../data/route_repository.dart';
import '../data/travel_route.dart';

class RouteFeedController extends ChangeNotifier {
  RouteFeedController({
    required RouteRepository routeRepository,
    required ProfileRepository profileRepository,
  })  : _repository = routeRepository,
        _profileRepository = profileRepository;

  final RouteRepository _repository;
  final ProfileRepository _profileRepository;

  List<TravelRoute> _feed = [];
  List<TravelRoute> _savedRoutes = [];
  final Map<String, _RouteLocalMedia> _localMediaByRouteId = {};
  final Map<String, String> _userAvatars = {};
  final Set<String> _busyRouteIds = {};
  bool _isLoadingFeed = false;
  bool _isLoadingSaved = false;
  bool _isCreatingRoute = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<TravelRoute> get feed => _feed;
  List<TravelRoute> get savedRoutes => _savedRoutes;
  List<TravelRoute> get filteredFeed =>
      _feed.where((route) => route.matches(_searchQuery)).toList();
  bool get isLoadingFeed => _isLoadingFeed;
  bool get isLoadingSaved => _isLoadingSaved;
  bool get isCreatingRoute => _isCreatingRoute;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get savedCount => _feed.where((route) => route.isSaved).length;

  bool isRouteBusy(String routeId) => _busyRouteIds.contains(routeId);

  TravelRoute? routeById(String routeId) {
    for (final route in _feed) {
      if (route.id == routeId) return route;
    }
    for (final route in _savedRoutes) {
      if (route.id == routeId) return route;
    }
    return null;
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> loadFeed() async {
    _isLoadingFeed = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _feed = _withLocalMedia(await _repository.getFeed());
      await _hydrateOwnerAvatars(_feed);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoadingFeed = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedRoutes() async {
    _isLoadingSaved = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _savedRoutes = _withLocalMedia(await _repository.getSavedRoutes());
      await _hydrateOwnerAvatars(_savedRoutes);
      for (final saved in _savedRoutes) {
        _replaceInFeed(saved.id, (route) => route.copyWith(isSaved: true));
      }
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoadingSaved = false;
      notifyListeners();
    }
  }

  Future<bool> toggleSave(TravelRoute route) async {
    final shouldSave = !route.isSaved;
    final previous = route;
    _setBusy(route.id, true);
    _applySaveState(route.id, shouldSave);

    try {
      if (shouldSave) {
        await _repository.saveRoute(route.id);
      } else {
        await _repository.unsaveRoute(route.id);
      }
      await loadSavedRoutes();
      return shouldSave;
    } on ApiException catch (error) {
      _replaceRoute(previous);
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setBusy(route.id, false);
    }
  }

  Future<void> createRoute(CreateRouteRequest request) async {
    _isCreatingRoute = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final routeId = await _repository.createRoute(request);
      if (routeId != null) {
        _localMediaByRouteId[routeId] = _RouteLocalMedia.fromRequest(request);
      }
      _feed = _withLocalMedia(await _repository.getFeed());
      await _hydrateOwnerAvatars(_feed);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _isCreatingRoute = false;
      notifyListeners();
    }
  }

  Future<void> deleteRoute(TravelRoute route) async {
    final previousFeed = List<TravelRoute>.from(_feed);
    final previousSaved = List<TravelRoute>.from(_savedRoutes);

    _setBusy(route.id, true);
    _removeRoute(route.id);

    try {
      await _repository.deleteRoute(route.id);
      final refreshedFeed = _withLocalMedia(await _repository.getFeed());
      if (refreshedFeed.any((item) => item.id == route.id)) {
        throw const ApiException(
          'Rota sunucuda silinmedi. RouteService yeniden baslatilmamis veya DELETE endpointi aktif degil.',
        );
      }

      _feed = refreshedFeed;
      await _hydrateOwnerAvatars(_feed);
      _savedRoutes = _withLocalMedia(await _repository.getSavedRoutes())
          .where((item) => item.id != route.id)
          .toList();
      await _hydrateOwnerAvatars(_savedRoutes);
      _localMediaByRouteId.remove(route.id);
    } on ApiException catch (error) {
      _feed = previousFeed;
      _savedRoutes = previousSaved;
      _errorMessage = error.message;
      notifyListeners();
      rethrow;
    } finally {
      _setBusy(route.id, false);
    }
  }

  Future<void> toggleLike(TravelRoute route) async {
    final shouldLike = !route.isLiked;
    final previous = route;
    _setBusy(route.id, true);
    _applyLikeState(route.id, shouldLike);

    try {
      if (shouldLike) {
        await _repository.likeRoute(route.id);
      } else {
        await _repository.unlikeRoute(route.id);
      }
    } on ApiException catch (error) {
      _replaceRoute(previous);
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setBusy(route.id, false);
    }
  }

  Future<void> likeRoute(TravelRoute route) => toggleLike(route);

  Future<List<RouteComment>> loadComments(String routeId) {
    return _repository.getComments(routeId);
  }

  Future<RouteComment> addComment({
    required String routeId,
    required String text,
  }) async {
    final comment = await _repository.addComment(routeId: routeId, text: text);
    _replaceInFeed(
      routeId,
      (route) => route.copyWith(commentsCount: route.commentsCount + 1),
    );
    _replaceInSaved(
      routeId,
      (route) => route.copyWith(commentsCount: route.commentsCount + 1),
    );
    notifyListeners();
    return comment;
  }

  void _applySaveState(String routeId, bool isSaved) {
    void update(List<TravelRoute> routes) {
      final index = routes.indexWhere((route) => route.id == routeId);
      if (index == -1) return;
      final route = routes[index];
      final nextSaves = route.savesCount + (isSaved ? 1 : -1);
      routes[index] = route.copyWith(
        isSaved: isSaved,
        savesCount: nextSaves < 0 ? 0 : nextSaves,
      );
    }

    update(_feed);
    update(_savedRoutes);
    if (!isSaved) {
      _savedRoutes =
          _savedRoutes.where((route) => route.id != routeId).toList();
    }
    notifyListeners();
  }

  void _applyLikeState(String routeId, bool isLiked) {
    void update(List<TravelRoute> routes) {
      final index = routes.indexWhere((route) => route.id == routeId);
      if (index == -1) return;
      final route = routes[index];
      final nextLikes = route.likesCount + (isLiked ? 1 : -1);
      routes[index] = route.copyWith(
        isLiked: isLiked,
        likesCount: nextLikes < 0 ? 0 : nextLikes,
      );
    }

    update(_feed);
    update(_savedRoutes);
    notifyListeners();
  }

  void _removeRoute(String routeId) {
    _feed = _feed.where((route) => route.id != routeId).toList();
    _savedRoutes = _savedRoutes.where((route) => route.id != routeId).toList();
    notifyListeners();
  }

  List<TravelRoute> _withLocalMedia(List<TravelRoute> routes) {
    return [
      for (final route in routes)
        _withCachedAvatar(
          _localMediaByRouteId[route.id]?.applyTo(route) ?? route,
        ),
    ];
  }

  Future<void> _hydrateOwnerAvatars(List<TravelRoute> routes) async {
    final usernames = routes
        .map((route) => route.ownerUsername.trim())
        .where((username) => username.isNotEmpty)
        .toSet();

    final missingUsernames =
        usernames.where((username) => !_userAvatars.containsKey(username));
    if (missingUsernames.isEmpty) return;

    await Future.wait(
      missingUsernames.map((username) async {
        try {
          final profile = await _profileRepository.getProfile(username);
          _userAvatars[username] = profile.profilePictureUrl.trim();
        } catch (_) {
          _userAvatars[username] = '';
        }
      }),
    );

    _feed = _feed.map(_withCachedAvatar).toList();
    _savedRoutes = _savedRoutes.map(_withCachedAvatar).toList();
  }

  TravelRoute _withCachedAvatar(TravelRoute route) {
    final cachedAvatar = _userAvatars[route.ownerUsername.trim()];
    if (cachedAvatar == null) return route;
    return route.copyWith(ownerAvatarUrl: cachedAvatar);
  }

  void _replaceRoute(TravelRoute route) {
    _replaceInFeed(route.id, (_) => route);
    final savedIndex = _savedRoutes.indexWhere((item) => item.id == route.id);
    if (savedIndex == -1 && route.isSaved) {
      _savedRoutes = [route, ..._savedRoutes];
    } else if (savedIndex != -1) {
      _savedRoutes[savedIndex] = route;
    }
    notifyListeners();
  }

  void _replaceInFeed(
    String routeId,
    TravelRoute Function(TravelRoute) update,
  ) {
    final index = _feed.indexWhere((route) => route.id == routeId);
    if (index != -1) {
      _feed[index] = update(_feed[index]);
    }
  }

  void _replaceInSaved(
    String routeId,
    TravelRoute Function(TravelRoute) update,
  ) {
    final index = _savedRoutes.indexWhere((route) => route.id == routeId);
    if (index != -1) {
      _savedRoutes[index] = update(_savedRoutes[index]);
    }
  }

  void _setBusy(String routeId, bool busy) {
    if (busy) {
      _busyRouteIds.add(routeId);
    } else {
      _busyRouteIds.remove(routeId);
    }
    notifyListeners();
  }
}

class _RouteLocalMedia {
  const _RouteLocalMedia({
    required this.coverImagePath,
    required this.stopPhotoPaths,
  });

  final String? coverImagePath;
  final List<List<String>> stopPhotoPaths;

  factory _RouteLocalMedia.fromRequest(CreateRouteRequest request) {
    return _RouteLocalMedia(
      coverImagePath: request.coverImageSource,
      stopPhotoPaths: [
        for (final stop in request.stops) List<String>.from(stop.photoSources),
      ],
    );
  }

  TravelRoute applyTo(TravelRoute route) {
    return route.copyWith(
      coverImageUrl: _preferLocal(coverImagePath, route.coverImageUrl),
      stops: [
        for (var index = 0; index < route.stops.length; index++)
          route.stops[index].copyWith(
            photoUrls: index < stopPhotoPaths.length &&
                    stopPhotoPaths[index].isNotEmpty
                ? stopPhotoPaths[index]
                : route.stops[index].photoUrls,
          ),
      ],
    );
  }

  String? _preferLocal(String? local, String? remote) {
    final trimmed = local?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return remote;
  }
}
