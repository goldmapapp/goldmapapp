import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/widgets/glass_container.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final topPadding = isWideScreen ? 16.0 : 86.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: isWindows
            ? Center(
                child: Text(
                  'Auth is disabled on Windows dev builds.',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black38,
                    fontSize: 16,
                  ),
                ),
              )
            : SignInScreen(
                providers: [
                  EmailAuthProvider(),
                ],
                headerBuilder: (context, constraints, _) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
