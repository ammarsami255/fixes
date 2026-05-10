import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart' show getIt;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state_event.dart';

/// Auth BLoC - handles all authentication logic
/// No Firebase code here - only uses use cases
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc()
      : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthResetPasswordRequested>(_onResetPassword);

    // Auto-check auth status on initialization
    add(AuthCheckRequested());
  }

  /// Get repository from DI container
  AuthRepository get _authRepository => getIt<AuthRepository>();

  /// Use cases
  GetCurrentUserUseCase get _getCurrentUser => GetCurrentUserUseCase(_authRepository);
  SignInWithEmailUseCase get _signInWithEmail => SignInWithEmailUseCase(_authRepository);
  SignInWithGoogleUseCase get _signInWithGoogle => SignInWithGoogleUseCase(_authRepository);
  RegisterWithEmailUseCase get _registerWithEmail => RegisterWithEmailUseCase(_authRepository);
  SignOutUseCase get _signOut => SignOutUseCase(_authRepository);
  SendPasswordResetUseCase get _sendPasswordReset => SendPasswordResetUseCase(_authRepository);

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _getCurrentUser();

    if (result.failure != null) {
      emit(AuthUnauthenticated());
      return;
    }

    if (result.user == null) {
      emit(AuthUnauthenticated());
      return;
    }

    final needsVerification = !result.user!.isEmailVerified;
    emit(AuthAuthenticated(user: result.user!, needsVerification: needsVerification));
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInWithEmail(
      email: event.email,
      password: event.password,
    );

    if (result.failure != null) {
      emit(AuthError(result.failure!.message));
      emit(AuthUnauthenticated());
      return;
    }

    final needsVerification = !result.user.isEmailVerified;
    emit(AuthAuthenticated(user: result.user, needsVerification: needsVerification));
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _signInWithGoogle();

    if (result.failure != null) {
      emit(AuthError(result.failure!.message));
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthAuthenticated(user: result.user));
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _registerWithEmail(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    if (result.failure != null) {
      emit(AuthError(result.failure!.message));
      emit(AuthUnauthenticated());
      return;
    }

    // After registration, require verification
    emit(AuthAuthenticated(
      user: result.user,
      needsVerification: true,
    ));
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final failure = await _signOut();

    if (failure != null) {
      emit(AuthError(failure.message));
      return;
    }

    emit(AuthUnauthenticated());
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final failure = await _sendPasswordReset(event.email);

    if (failure != null) {
      emit(AuthError(failure.message));
      return;
    }

    emit(AuthUnauthenticated());
  }
}

/// Type alias for getting AuthRepository from DI container
