import 'package:goldmapapp/features/user_system/auth/domain/entities/app_user.dart';
import 'package:goldmapapp/features/user_system/auth/domain/repositories/auth_repo.dart';

class SignUpWithEmail {
  SignUpWithEmail(this._repo);

  final AuthRepo _repo;

  Future<AppUser?> call({
    required String email,
    required String password,
  }) {
    return _repo.signUpWithEmail(email: email, password: password);
  }
}
