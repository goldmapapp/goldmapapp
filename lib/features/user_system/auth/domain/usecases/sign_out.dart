import 'package:goldmapapp/features/user_system/auth/domain/repositories/auth_repo.dart';

class SignOut {
  SignOut(this._repo);

  final AuthRepo _repo;

  Future<void> call() => _repo.signOut();
}
