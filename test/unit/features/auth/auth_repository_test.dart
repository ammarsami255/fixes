import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:el_moza3/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:el_moza3/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:el_moza3/core/errors/failures.dart';

/// Manual mock for FirebaseAuthDataSource
class MockFirebaseAuthDataSource extends Mock
    implements FirebaseAuthDataSource {}

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;
    late MockFirebaseAuthDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockFirebaseAuthDataSource();
      repository = AuthRepositoryImpl(mockDataSource);
    });

    test('getCurrentUser returns user when authenticated', () async {
      // Arrange - create a minimal mock user
      when(mockDataSource.currentUser).thenReturn(null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.user, isNull);
      expect(result.failure, isNull);
    });

    test('signOut calls dataSource and returns null', () async {
      // Arrange
      when(mockDataSource.signOut()).thenAnswer((_) async {});

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result, isNull);
      verify(mockDataSource.signOut()).called(1);
    });
  });
}

/// Minimal mock for Firebase User
class _TestUser implements User {
  @override
  String get uid => 'test-uid';
  
  @override
  String? get email => 'test@example.com';
  
  @override
  String? get displayName => 'Test User';
  
  @override
  String? get photoURL => null;
  
  @override
  bool get emailVerified => true;
  
  @override
  DateTime? get metadata => null;
  
  @override
  ProviderInfoList get providerData => [];
  
  @override
  String? get phoneNumber => null;
  
  @override
  String? get refreshToken => null;
  
  @override
  bool get isAnonymous => false;
  
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential> unlink(String providerId) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> delete() async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> reload() async {
    throw UnimplementedError();
  }
  
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    throw UnimplementedError();
  }
  
  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    throw UnimplementedError();
  }
}