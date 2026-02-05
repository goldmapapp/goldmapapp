import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}

// Server Failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// Authentication Failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

// Unknown Failure
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
