import 'package:equatable/equatable.dart';

/// Auth user entity
class AuthUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime? createdAt;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified,
    this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isEmailVerified, createdAt];
}