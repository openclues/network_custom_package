import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../error/http_failuar.dart';
import 'http_service.dart';

class DioServiceImpl implements HttpService {
  final Dio _dio;

  DioServiceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<HttpFailure, T?>> get<T>({
    required String url,
    String? fullUrl,
    bool? toLiveRatesProvider,
    required T? Function(dynamic p1) fromJson,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        onReceiveProgress: onReceiveProgress,
        url,
      );
      print('url: $url');
      print('fullUrl: $fullUrl');
      print(response.data);
      return Right(fromJson(response.data));
    } catch (error) {
      print('error: $error');
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> post<T>({
    required String url,
    required T? Function(dynamic p1) fromJson,
    dynamic body,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        onSendProgress: (sent, total) {},
        options: Options(responseType: ResponseType.plain),
      );
      print('url: $url');
      print(response.data);
      return Right((fromJson(jsonDecode(response.data))));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> delete<T>(
      {required String url, required T? Function(dynamic p1) fromJson}) async {
    try {
      final response = await _dio.delete(url);
      return Right(fromJson(response.data));
    } catch (error) {
      return Left(errorFromDioError(error));
    }
  }

  @override
  Future<Either<HttpFailure, T?>> patch<T>(
      {required String url, required T? Function(dynamic p1) fromJson, body}) {
    // TODO: implement patch
    throw UnimplementedError();
  }

  @override
  Future<Either<HttpFailure, T?>> put<T>(
      {required String url, required T? Function(dynamic p1) fromJson, body}) {
    // TODO: implement put
    throw UnimplementedError();
  }

  @override
  Future<Either<HttpFailure, T?>> request<T>(
      {required String url,
      required T? Function(dynamic p1) fromJson,
      required String method,
      body}) {
    // TODO: implement request
    throw UnimplementedError();
  }
}

HttpFailure errorFromDioError(dynamic error) {
  print('error: $error');
  if (error is DioException) {
    if (error.response != null) {
      return ServerHttpFailure(error.response.toString(),
          code: error.response!.statusCode,
          statusCode: error.response!.statusCode);
    } else {
      return ServerHttpFailure(error.message ?? 'Something Went Wrong');
    }
  } else {
    return const InternalAppHttpFailure('Something Went Wrong');
  }
}
