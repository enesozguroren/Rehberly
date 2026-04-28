import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../data/route_comment.dart';
import '../data/route_repository.dart';
import '../data/travel_route.dart';

class RouteFeedController extends ChangeNotifier {
  RouteFeedController(this._repository);

  final RouteRepository _repository;

  List<TravelRoute> _feed = [];
  List<TravelRoute> _savedRoutes = [];
  final Set<String> _busyRouteIds = {};
  bool _isLoadingFeed = false;
  bool _isLoadingSaved = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<TravelRoute> get feed => _feed;
  List<TravelRoute> get savedRoutes => _savedRoutes;
  List<TravelRoute> get filteredFeed =>
      _feed.where((route) => route.matches(_searchQuery)).toList();
  bool get isLoadingFeed => _isLoadingFeed;
  bool get isLoadingSaved => _isLoadingSaved;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get savedCount => _feed.where((route) => route.isSaved).length;

  bool isRouteBusy(String routeId) => _busyRouteIds.contains(routeId);

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> loadFeed() async {
    _isLoadingFeed = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _feed = await _repository.getFeed();
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
      _savedRoutes = await _repository.getSavedRoutes();
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

  Future<void> likeRoute(TravelRoute route) async {
    if (route.isLiked) {
      return;
    }

    final previous = route;
    _setBusy(route.id, true);
    _replaceRoute(
      route.copyWith(
        isLiked: true,
        likesCount: route.likesCount + 1,
      ),
    );

    try {
      await _repository.likeRoute(route.id);
    } on ApiException catch (error) {
      _replaceRoute(previous);
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setBusy(route.id, false);
    }
  }

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
      _savedRoutes = _savedRoutes.where((route) => route.id != routeId).toList();
    }
    notifyListeners();
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

  void _replaceInFeed(String routeId, TravelRoute Function(TravelRoute) update) {
    final index = _feed.indexWhere((route) => route.id == routeId);
    if (index != -1) {
      _feed[index] = update(_feed[index]);
    }
  }

  void _replaceInSaved(String routeId, TravelRoute Function(TravelRoute) update) {
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
