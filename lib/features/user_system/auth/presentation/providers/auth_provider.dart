import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/features/user_system/auth/data/datasources/auth_remote.dart';
import 'package:goldmapapp/features/user_system/auth/data/repositories/auth_repo_impl.dart';
import 'package:goldmapapp/features/user_system/auth/domain/entities/app_user.dart';
import 'package:goldmapapp/features/user_system/auth/domain/repositories/auth_repo.dart';
import 'package:goldmapapp/features/user_system/auth/domain/usecases/auth_state_changes.dart';
import 'package:goldmapapp/features/user_system/auth/domain/usecases/send_password_reset.dart';
import 'package:goldmapapp/features/user_system/auth/domain/usecases/sign_in_email.dart';
import 'package:goldmapapp/features/user_system/auth/domain/usecases/sign_out.dart';
import 'package:goldmapapp/features/user_system/auth/domain/usecases/sign_up_email.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRemoteProvider = Provider<AuthRemote>((ref) {
  return AuthRemote(ref.watch(firebaseAuthProvider));
});

final authRepoProvider = Provider<AuthRepo>((ref) {
  final isWindows =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  if (isWindows) {
    return _NoopAuthRepo();
  }
  return AuthRepoImpl(ref.watch(authRemoteProvider));
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return AuthStateChanges(ref.watch(authRepoProvider))();
});

final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.watch(authRepoProvider));
});

final signUpWithEmailProvider = Provider<SignUpWithEmail>((ref) {
  return SignUpWithEmail(ref.watch(authRepoProvider));
});

final sendPasswordResetProvider = Provider<SendPasswordReset>((ref) {
  return SendPasswordReset(ref.watch(authRepoProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepoProvider));
});

class _NoopAuthRepo implements AuthRepo {
  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
}
