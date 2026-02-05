import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/widgets/glass_container.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final topPadding = isWideScreen ? 16.0 : 86.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
      child: GlassContainer(
        child: Center(
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black38,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
