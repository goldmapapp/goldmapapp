import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/widgets/metal_price_chart.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GoldMapApp(),
    ),
  );
}

class GoldMapApp extends ConsumerWidget {
  const GoldMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp(
      title: 'GoldMapApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.white,
        colorScheme: isDark
            ? ColorScheme.dark(
                primary: const Color(0xFFFFD700),
                secondary: const Color(0xFF64FFDA),
                surface: Colors.white.withValues(alpha: 0.05),
              )
            : const ColorScheme.light(
                primary: Color(0xFFFFD700),
                secondary: Color(0xFF64FFDA),
              ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _showSettings() {
    final isDark = ref.read(themeProvider);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                          Navigator.pop(context);
                        },
                        activeTrackColor: const Color(0xFFFFD700),
                        activeThumbColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final isDark = ref.watch(themeProvider);

    final navigationBar = Container(
      margin: EdgeInsets.all(isWideScreen ? 16 : 0),
      padding: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 0 : 8,
        vertical: isWideScreen ? 0 : 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: isWideScreen ? BorderRadius.circular(16) : null,
        border: isWideScreen
            ? Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
              )
            : null,
        boxShadow: isWideScreen
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: isWideScreen ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceEvenly,
        children: isWideScreen ? _buildNavItems(true) : _buildSquareButtons(),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF4A5568),
                    const Color(0xFF2D3748),
                    const Color(0xFF1A202C),
                  ]
                : [
                    const Color(0xFFF5F5F7),
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF0F0F2),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (isWideScreen) navigationBar,
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: GlassContainer(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: MetalPriceChart(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isWideScreen ? null : navigationBar,
    );
  }

  List<Widget> _buildNavItems(bool isWideScreen) {
    final items = [
      {'icon': Icons.show_chart_rounded, 'label': 'Markets', 'index': 0},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Portfolio', 'index': 1},
      {'icon': Icons.notifications_rounded, 'label': 'Alerts', 'index': 2},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'index': 3},
    ];
    final isDark = ref.watch(themeProvider);

    return items.map((item) {
      final isSelected = _selectedIndex == item['index'];
      final index = item['index']! as int;
      return InkWell(
        onTap: () {
          if (index == 3) {
            _showSettings();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Icon(
                item['icon']! as IconData,
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : isDark
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                item['label']! as String,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : isDark
                          ? Colors.white
                          : Colors.black.withValues(alpha: 0.5),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSquareButtons() {
    final items = [
      {'icon': Icons.show_chart_rounded, 'index': 0},
      {'icon': Icons.account_balance_wallet_rounded, 'index': 1},
      {'icon': Icons.notifications_rounded, 'index': 2},
      {'icon': Icons.settings_rounded, 'index': 3},
    ];
    final isDark = ref.watch(themeProvider);

    return items.map((item) {
      final isSelected = _selectedIndex == item['index'];
      final index = item['index']! as int;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (index == 3) {
              _showSettings();
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                item['icon']! as IconData,
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : isDark
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class GlassContainer extends ConsumerWidget {
  const GlassContainer({
    required this.child,
    this.width,
    this.height,
    this.padding,
    super.key,
  });
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        // Futuristic glass effect - very subtle background that adapts to theme
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
