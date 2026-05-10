/// Core failures for domain layer error handling
abstract class Failure {
  final String message;
  final String? code;
  final bool requiresVerification = false;
  
  const Failure({required this.message, this.code});
  
  @override
  String toString() => 'Failure: $message (code: $code)';
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}