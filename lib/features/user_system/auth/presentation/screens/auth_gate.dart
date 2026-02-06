import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/features/user_system/auth/presentation/providers/auth_provider.dart';
import 'package:goldmapapp/features/user_system/auth/presentation/screens/login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWindows =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    if (isWindows) {
      return child;
    }
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        // TODO(omega): route to onboarding if first-time user
        return user == null ? const LoginScreen() : child;
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Auth error: $err'),
      ),
    );
  }
}
