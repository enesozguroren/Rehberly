import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response != null) {
      return ApiException(
        _messageFromBody(response.data) ??
            _fallbackForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    return const ApiException(
      'API sunucusuna ulasilamadi. Servislerin calistigini ve IP ayarini kontrol edin.',
    );
  }

  static String? _messageFromBody(Object? body) {
    if (body is String && body.trim().isNotEmpty) {
      return body;
    }

    if (body is Map) {
      final message = body['message'] ?? body['title'] ?? body['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }
    }

    return null;
  }

  static String _fallbackForStatus(int? statusCode) {
    if (statusCode == null) return 'Beklenmeyen bir hata olustu.';
    return switch (statusCode) {
      400 => 'Istek gecersiz. Bilgileri kontrol edin.',
      401 => 'Oturum suresi dolmus olabilir. Tekrar giris yapin.',
      403 => 'Bu islem icin yetkiniz yok.',
      404 => 'Istenen kaynak bulunamadi.',
      >= 500 => 'Sunucuda beklenmeyen bir hata olustu.',
      _ => 'Beklenmeyen bir hata olustu.',
    };
  }

  @override
  String toString() => message;
}
