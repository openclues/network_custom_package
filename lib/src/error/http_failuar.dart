import 'dart:async';
import 'dart:io';

import 'http_errors.dart';
import 'package:dartz/dartz.dart';

abstract class HttpFailure {
  final String message;
  final int? code;
  final int? statusCode;

  const HttpFailure(this.message, {this.code, this.statusCode});
}

class ServerHttpFailure extends HttpFailure {
  const ServerHttpFailure(super.message, {super.code, super.statusCode});
}

class InternalAppHttpFailure extends HttpFailure {
  const InternalAppHttpFailure(super.message, {super.code, super.statusCode});
}

class NoInternetConnectionHttpFailure extends HttpFailure {
  const NoInternetConnectionHttpFailure(super.message);
}

class TimeoutHttpFailure extends HttpFailure {
  const TimeoutHttpFailure(super.message);
}

class NotAuthorizedHttpFailure extends HttpFailure {
  const NotAuthorizedHttpFailure(super.message,
      {super.code, super.statusCode = HttpStatus.unauthorized});
}

Either<HttpFailure, T> handleException<T>(dynamic exception) {
  if (exception is HttpException) {
    return left(ServerHttpFailure(exception.message,
        code: exception.code, statusCode: exception.statusCode));
  } else if (exception is SocketException) {
    return left(NoInternetConnectionHttpFailure(exception.message));
  } else if (exception is TimeoutException) {
    return left(TimeoutHttpFailure(exception.message ?? 'Operation timed out'));
  } else if (exception is NotAuthenticatedHttpException) {
    return left(NotAuthorizedHttpFailure(exception.message));
  } else {
    return left(const InternalAppHttpFailure('Something Went Wrong'));
  }
}
