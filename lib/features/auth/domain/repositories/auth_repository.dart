import '../entities/auth_user.dart';
import '../../../../core/errors/failures.dart';

/// Abstract auth repository - NO Firebase code here
/// This is the contract that the data layer must implement
abstract class AuthRepository {
  /// Get current authenticated user
  Future<({AuthUser?, Failure?}) getCurrentUser();

  /// Sign in with email and password
  Future<({AuthUser user, Failure?}) signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<({AuthUser user, Failure?}) signInWithGoogle();

  /// Register with email and password
  Future<({AuthUser user, Failure?}) registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  /// Sign out
  Future<Failure?> signOut();

  /// Send password reset email
  Future<Failure?> sendPasswordReset(String email);

  /// Send verification email
  Future<Failure?> sendVerificationEmail();

  /// Check if user is verified
  Future<({bool isVerified, Failure?}) isUserVerified();

  /// Stream of auth state changes
  Stream<AuthUser?> get authStateChanges;

  /// Check if currently logged in
  bool get isLoggedIn;
}