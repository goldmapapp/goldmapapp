import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/features/user_settings/user_settings_page.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/widgets/glass_container.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final topPadding = isWideScreen ? 16.0 : 86.0;
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final user = isWindows ? null : FirebaseAuth.instance.currentUser;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'User Settings',
                  icon: Icon(
                    Icons.settings_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const UserSettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isWindows)
              Text(
                'Profile unavailable on Windows dev builds.',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black38,
                  fontSize: 16,
                ),
              )
            else if (user == null)
              Text(
                'Not signed in.',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black38,
                  fontSize: 16,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.email ?? 'No email on file',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID: ${user.uid}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
