import 'package:goldmapapp/features/user_system/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();
}
