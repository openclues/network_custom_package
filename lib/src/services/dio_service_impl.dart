import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import '../error/http_failuar.dart';
import 'http_service.dart';
import 'token_interceptor.dart';

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class NetworkService implements HttpService {
  final Dio _dio;
  final Logger _logger = Logger('NetworkService'); // Logger instance

  NetworkService({required Dio options}) : _dio = options;

  static Dio options({
    required String baseUrl,
    Future<String?> Function()? getToken,
  }) {
    setupLogging();

    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    if (getToken != null) {
      dio.interceptors.add(TokenInterceptor(getToken));
    }
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger('NetworkService').info('Request URL: ${options.uri}');
        Logger('NetworkService').info('Request Headers: ${options.headers}');
        Logger('NetworkService').info('Request Body: ${options.data}');
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        Logger('NetworkService').severe('Error: ${error.message}');
        Logger('NetworkService').severe('Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
    return dio;
  }

  @override
  Future<Either<HttpFailure, T?>> get<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    bool requireToken = false,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(extra: {'requireToken': requireToken}),
        onReceiveProgress: onReceiveProgress,
      );
      _logger.info('GET Response: ${response.data}');
      return Right(fromJson(response.data));
    } catch (error) {
      _logger.severe('GET Error: $error');
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> post<T>({
    required String url,
    T? Function(dynamic p1)? fromJson,
    dynamic body,
    bool requireToken = false,
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

      // Handle empty responses (e.g., 204 No Content)
      if (response.statusCode == 204 || response.data == null) {
        _logger.info('POST Response: Empty (204 No Content)');
        return Right(null);
      }

      // Parse response if fromJson is provided
      _logger.info('POST Response: ${response.data}');
      return Right(
          fromJson != null ? fromJson(jsonDecode(response.data)) : null);
    } catch (error) {
      _logger.severe('POST Error: $error');
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> upload<T>({
    required String url,
    required String filePath,
    required String fileKey,
    Map<String, dynamic>? formData,
    required T? Function(dynamic p1) fromJson,
    required bool requireToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final file = await MultipartFile.fromFile(filePath);
      final data = FormData.fromMap({
        ...?formData,
        fileKey: file,
      });

      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          extra: {'requireToken': requireToken},
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );

      _logger.info('Upload Response: ${response.data}');
      return Right(fromJson(jsonDecode(response.data)));
    } catch (error) {
      _logger.severe('Upload Error: $error');
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> put<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    dynamic body,
    bool requireToken = false,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        options: Options(extra: {'requireToken': requireToken}),
      );
      _logger.info('PUT Response: ${response.data}');
      return Right(fromJson(response.data));
    } catch (error) {
      _logger.severe('PUT Error: $error');
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> patch<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    dynamic body,
    bool requireToken = false,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: body,
        options: Options(extra: {'requireToken': requireToken}),
      );
      _logger.info('PATCH Response: ${response.data}');
      return Right(fromJson(response.data));
    } catch (error) {
      _logger.severe('PATCH Error: $error');
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> delete<T>({
    required String url,
    T? Function(dynamic p1)? fromJson,
    bool requireToken = false,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        options: Options(extra: {'requireToken': requireToken}),
      );

      // Handle empty responses (e.g., 204 No Content)
      if (response.statusCode == 204 || response.data == null) {
        _logger.info('DELETE Response: Empty (204 No Content)');
        return Right(null);
      }

      // Parse response if fromJson is provided
      _logger.info('DELETE Response: ${response.data}');
      return Right(fromJson != null ? fromJson(response.data) : null);
    } catch (error) {
      _logger.severe('DELETE Error: $error');
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> request<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    required String method,
    dynamic body,
    bool requireToken = false,
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
          _logger.severe('Unsupported HTTP method: $method');
          return Left(InternalAppHttpFailure('Method not supported'));
      }
      _logger.info('$method Response: ${response.data}');
      return Right(fromJson(response.data));
    } catch (error) {
      _logger.severe('$method Error: $error');
      return Left(errorFromDioError(error));
    }
  }
}

HttpFailure errorFromDioError(dynamic error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final message = error.message ?? 'Something went wrong';
    final responseData = error.response?.data;

    if (statusCode != null) {
      return ServerHttpFailure(
        responseData?.toString() ?? message,
        code: statusCode,
        statusCode: statusCode,
      );
    }
    return InternalAppHttpFailure(message);
  }
  return const InternalAppHttpFailure('Something went wrong');
}
