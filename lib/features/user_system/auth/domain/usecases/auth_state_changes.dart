import 'package:goldmapapp/features/user_system/auth/domain/entities/app_user.dart';
import 'package:goldmapapp/features/user_system/auth/domain/repositories/auth_repo.dart';

class AuthStateChanges {
  AuthStateChanges(this._repo);

  final AuthRepo _repo;

  Stream<AppUser?> call() => _repo.authStateChanges();
}
