import 'package:goldmapapp/features/user_system/auth/domain/repositories/auth_repo.dart';

class SendPasswordReset {
  SendPasswordReset(this._repo);

  final AuthRepo _repo;

  Future<void> call({required String email}) {
    return _repo.sendPasswordResetEmail(email: email);
  }
}
