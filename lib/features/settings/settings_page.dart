import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/widgets/glass_container.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final topPadding = isWideScreen ? 16.0 : 86.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).state = value;
                  },
                  activeTrackColor: const Color(0xFFD4A84B),
                  activeThumbColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
