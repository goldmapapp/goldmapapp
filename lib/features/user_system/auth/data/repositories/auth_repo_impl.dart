import 'package:goldmapapp/features/user_system/auth/data/datasources/auth_remote.dart';
import 'package:goldmapapp/features/user_system/auth/domain/entities/app_user.dart';
import 'package:goldmapapp/features/user_system/auth/domain/repositories/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._remote);

  final AuthRemote _remote;

  @override
  Stream<AppUser?> authStateChanges() => _remote.authStateChanges();

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _remote.signInWithEmail(email: email, password: password);
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _remote.signUpWithEmail(email: email, password: password);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _remote.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() {
    return _remote.signOut();
  }
}
