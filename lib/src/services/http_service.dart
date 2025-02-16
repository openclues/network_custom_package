import 'package:dartz/dartz.dart';

import '../error/http_failuar.dart';

abstract class HttpService {
  Future<Either<HttpFailure, T?>> get<T>({
    required String url,
    required T? Function(dynamic) fromJson,
    required bool requireToken,
  });

  Future<Either<HttpFailure, T?>> post<T>({
    required String url,
    required T? Function(dynamic) fromJson,
    required bool requireToken,
    dynamic body,
  });
  Future<Either<HttpFailure, T?>> upload<T>({
    required String url,
    required String filePath,
    required String fileKey,
    Map<String, dynamic>? formData,
    required T? Function(dynamic p1) fromJson,
    bool requireToken = true,
    void Function(int sent, int total)? onSendProgress,
  });
  Future<Either<HttpFailure, T?>> put<T>({
    required bool requireToken,
    required String url,
    required T? Function(dynamic) fromJson,
    dynamic body,
  });

  Future<Either<HttpFailure, T?>> delete<T>({
    required bool requireToken,
    required String url,
    required T? Function(dynamic) fromJson,
  });

  Future<Either<HttpFailure, T?>> patch<T>({
    required bool requireToken,
    required String url,
    required T? Function(dynamic) fromJson,
    dynamic body,
  });

  Future<Either<HttpFailure, T?>> request<T>({
    required bool requireToken,
    required String url,
    required T? Function(dynamic) fromJson,
    required String method,
    dynamic body,
  });
}
