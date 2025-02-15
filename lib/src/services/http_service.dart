import 'package:dartz/dartz.dart';

import '../error/http_failuar.dart';

abstract class HttpService {
  Future<Either<HttpFailure, T?>> get<T>({
    required String url,
    required T? Function(dynamic) fromJson,
  });

  Future<Either<HttpFailure, T?>> post<T>({
    required String url,
    required T? Function(dynamic) fromJson,
    dynamic body,
  });

  Future<Either<HttpFailure, T?>> put<T>({
    required String url,
    required T? Function(dynamic) fromJson,
    dynamic body,
  });

  Future<Either<HttpFailure, T?>> delete<T>({
    required String url,
    required T? Function(dynamic) fromJson,
  });

  Future<Either<HttpFailure, T?>> patch<T>({
    required String url,
    required T? Function(dynamic) fromJson,
    dynamic body,
  });

  Future<Either<HttpFailure, T?>> request<T>({
    required String url,
    required T? Function(dynamic) fromJson,
    required String method,
    dynamic body,
  });
}
