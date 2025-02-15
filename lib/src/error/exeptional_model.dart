import 'package:equatable/equatable.dart';

class ExceptionModel extends Equatable {
  final String message;
  final int? code;

  const ExceptionModel({required this.message, this.code});

  factory ExceptionModel.fromJson(Map<String, dynamic> json) {
    return ExceptionModel(message: json['message'], code: json['code']);
  }

  @override
  List<Object?> get props => [message, code];
}
