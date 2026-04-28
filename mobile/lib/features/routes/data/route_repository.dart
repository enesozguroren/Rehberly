import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import 'route_comment.dart';
import 'travel_route.dart';

class RouteRepository {
  RouteRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TravelRoute>> getFeed() async {
    try {
      final response = await _apiClient.route.get<List<dynamic>>('/api/Route/feed');
      return _mapRoutes(response.data ?? []);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<TravelRoute>> getSavedRoutes() async {
    try {
      final response = await _apiClient.route.get<List<dynamic>>('/api/Route/saved');
      return _mapRoutes(response.data ?? []);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> saveRoute(String routeId) async {
    try {
      await _apiClient.route.post<void>('/api/Route/$routeId/save');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> unsaveRoute(String routeId) async {
    try {
      await _apiClient.route.delete<void>('/api/Route/$routeId/save');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> likeRoute(String routeId) async {
    try {
      await _apiClient.route.post<void>('/api/Route/$routeId/like');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<RouteComment>> getComments(String routeId) async {
    try {
      final response = await _apiClient.route.get<List<dynamic>>(
        '/api/Route/$routeId/comments',
      );
      return (response.data ?? [])
          .map((item) => RouteComment.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<RouteComment> addComment({
    required String routeId,
    required String text,
  }) async {
    try {
      final response = await _apiClient.route.post<Map<String, dynamic>>(
        '/api/Route/$routeId/comment',
        data: {'text': text.trim()},
      );
      return RouteComment.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  List<TravelRoute> _mapRoutes(List<dynamic> data) {
    return data
        .map((item) => TravelRoute.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
