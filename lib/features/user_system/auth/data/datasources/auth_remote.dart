import 'package:firebase_auth/firebase_auth.dart';
import 'package:goldmapapp/features/user_system/auth/domain/entities/app_user.dart';

class AuthRemote {
  AuthRemote(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Stream<AppUser?> authStateChanges() {
    // TODO(omega): expand AppUser mapping when profile fields exist
    return _firebaseAuth.authStateChanges().map(_toAppUser);
  }

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // TODO(omega): handle FirebaseAuth exceptions with user-friendly messages
    final result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAppUser(result.user);
  }

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // TODO(omega): handle FirebaseAuth exceptions with user-friendly messages
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAppUser(result.user);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    // TODO(omega): handle FirebaseAuth exceptions with user-friendly messages
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  AppUser? _toAppUser(User? user) {
    if (user == null || user.email == null) {
      return null;
    }
    return AppUser(id: user.uid, email: user.email!);
  }
}
