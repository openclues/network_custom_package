import 'dart:io';

class HttpException implements Exception {
  final String message;
  final int? statusCode;
  final int? code;
  const HttpException(this.message, {this.statusCode, this.code});

  @override
  String toString() {
    return message;
  }
}

class NotAuthenticatedHttpException implements Exception {
  final String message;
  final int? statusCode;

  const NotAuthenticatedHttpException(
    this.message, {
    this.statusCode = HttpStatus.unauthorized,
  });

  @override
  String toString() {
    return message;
  }
}
