import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  final Future<String?> Function() getToken; // Allow nullable token

  TokenInterceptor(this.getToken);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requireToken =
        options.extra['requireToken'] ?? false; // Default to false
    if (requireToken) {
      final token = await getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        // Handle null token case (e.g., log or throw an error)
        handler.reject(DioException(
          requestOptions: options,
          error: 'Token is required but not available',
        ));
        return;
      }
    }
    handler.next(options);
  }
}
