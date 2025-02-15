import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../error/http_failuar.dart';
import 'http_service.dart';

class TokenInterceptor extends Interceptor {
  final Future<String> Function() getToken;

  TokenInterceptor(this.getToken);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requireToken = options.extra['requireToken'] ?? true;
    if (requireToken) {
      final token = await getToken();
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class RefreshTokenInterceptor extends Interceptor {
  final Future<String> Function() refreshToken;

  RefreshTokenInterceptor(this.refreshToken);

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final requireToken = err.requestOptions.extra['requireToken'] ?? true;
      if (requireToken) {
        final newToken = await refreshToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        return handler.resolve(await Dio().fetch(err.requestOptions));
      }
    }
    handler.next(err);
  }
}

class NetworkService implements HttpService {
  final Dio _dio;

  NetworkService({required Dio options}) : _dio = options;

  static Dio options({
    required String baseUrl,
    Future<String> Function()? getToken,
    Future<String> Function()? refreshToken,
  }) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.addAll([
      if (getToken != null) TokenInterceptor(getToken),
      if (refreshToken != null) RefreshTokenInterceptor(refreshToken),
    ]);
    return dio;
  }

  @override
  Future<Either<HttpFailure, T?>> get<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    bool requireToken = true,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'requireToken': requireToken}),
        onReceiveProgress: onReceiveProgress,
      );
      return Right(fromJson(response.data));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> post<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    dynamic body,
    bool requireToken = true,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          extra: {'requireToken': requireToken},
          responseType: ResponseType.plain,
        ),
        onSendProgress: onSendProgress,
      );
      return Right(fromJson(jsonDecode(response.data)));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> put<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    dynamic body,
    bool requireToken = true,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        options: Options(extra: {'requireToken': requireToken}),
      );
      return Right(fromJson(response.data));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> patch<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    dynamic body,
    bool requireToken = true,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: body,
        options: Options(extra: {'requireToken': requireToken}),
      );
      return Right(fromJson(response.data));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> delete<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    bool requireToken = true,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        options: Options(extra: {'requireToken': requireToken}),
      );
      return Right(fromJson(response.data));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> request<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    required String method,
    dynamic body,
    bool requireToken = true,
  }) async {
    try {
      Response response;
      final options = Options(
        extra: {'requireToken': requireToken},
        method: method,
      );

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(url, options: options);
          break;
        case 'POST':
          response = await _dio.post(url, data: body, options: options);
          break;
        case 'PUT':
          response = await _dio.put(url, data: body, options: options);
          break;
        case 'DELETE':
          response = await _dio.delete(url, options: options);
          break;
        case 'PATCH':
          response = await _dio.patch(url, data: body, options: options);
          break;
        default:
          return Left(InternalAppHttpFailure('Method not supported'));
      }
      return Right(fromJson(response.data));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }
}

HttpFailure errorFromDioError(dynamic error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final message = error.message ?? 'Something went wrong';

    if (statusCode != null) {
      return ServerHttpFailure(
        error.response.toString(),
        code: statusCode,
        statusCode: statusCode,
      );
    }
    return InternalAppHttpFailure(message);
  }
  return const InternalAppHttpFailure('Something went wrong');
}
