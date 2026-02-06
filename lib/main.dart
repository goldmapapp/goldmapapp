import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goldmapapp/features/events/events_page.dart';
import 'package:goldmapapp/features/map/map_page.dart';
import 'package:goldmapapp/features/markets/markets_page.dart';
import 'package:goldmapapp/features/messages/messages_page.dart';
import 'package:goldmapapp/features/profile/profile_page.dart';
import 'package:goldmapapp/features/settings/settings_page.dart';
import 'package:goldmapapp/features/signup/signup_page.dart';
import 'package:goldmapapp/features/trade/trade_page.dart';
import 'package:goldmapapp/features/user_system/auth/presentation/providers/auth_provider.dart';
import 'package:goldmapapp/features/user_system/auth/presentation/screens/auth_gate.dart';
import 'package:goldmapapp/firebase_options.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  if (!isWindows) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
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
        scaffoldBackgroundColor: isDark ? const Color(0xFF3D3D3D) : Colors.white,
        colorScheme: isDark
            ? ColorScheme.dark(
                primary: const Color(0xFFD4A84B),
                secondary: const Color(0xFF64FFDA),
                surface: Colors.white.withValues(alpha: 0.05),
              )
            : const ColorScheme.light(
                primary: Color(0xFFD4A84B),
                secondary: Color(0xFF64FFDA),
              ),
      ),
      home: const AuthGate(child: HomePage()),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _desktopFlashController;
  late Animation<double> _desktopFlashOpacity;
  bool _showDesktopMenu = false;
  bool _showDesktopBar = false;
  bool _wasWideScreen = false;
  static const String _logoAssetPath = 'assets/images/north-america-unified-final.svg';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _desktopFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _desktopFlashOpacity = CurvedAnimation(
      parent: _desktopFlashController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _desktopFlashController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final isDark = ref.watch(themeProvider);
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final authState = ref.watch(authStateChangesProvider);
    final isAuthed = !isWindows && authState.asData?.value != null;
    const menuShowDuration = Duration(milliseconds: 650);
    final enteringDesktop = isWideScreen && !_wasWideScreen;
    final leavingDesktop = !isWideScreen && _wasWideScreen;
    _wasWideScreen = isWideScreen;
    if (enteringDesktop) {
      _showDesktopBar = true;
      _showDesktopMenu = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _desktopFlashController.forward(from: 0).then((_) => _desktopFlashController.reverse());
          setState(() {
            _showDesktopMenu = true;
          });
        }
      });
    }
    if (leavingDesktop) {
      _showDesktopMenu = false;
      _showDesktopBar = false;
    }
    // Desktop navigation bar with logo
    final menuButtons = _buildSquareButtons(isAuthed: isAuthed, showLabels: true);
    final desktopNavBar = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.35),
          ),
          child: Row(
            children: [
              _buildLogoBox(),
              Expanded(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return TweenAnimationBuilder<double>(
                            duration: _showDesktopMenu ? menuShowDuration : Duration.zero,
                            curve: Curves.easeInOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: _showDesktopMenu ? 1 : 0,
                            ),
                            builder: (context, value, child) {
                              return ClipRect(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: value,
                                  child: SizedBox(
                                    width: constraints.maxWidth,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Row(children: menuButtons),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _desktopFlashController,
                          builder: (context, _) {
                            final opacity = _desktopFlashOpacity.value;
                            if (opacity <= 0) {
                              return const SizedBox.shrink();
                            }
                            return Opacity(
                              opacity: opacity * 0.25,
                              child: Container(
                                color: const Color(0xFFD4A84B).withValues(alpha: 0.35),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Mobile navigation bar WITHOUT logo
    final mobileNavBar = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.35),
          ),
          child: Row(
            children: _buildSquareButtons(isAuthed: isAuthed),
          ),
        ),
      ),
    );

    // Mobile top logo bar (overlay) - taller with left-aligned logo
    final mobileLogoBar = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.35),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildLogoContent(),
          ),
        ),
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
                    const Color(0xFF5A5A5A),
                    const Color(0xFF454545),
                    const Color(0xFF3D3D3D),
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
              if (_showDesktopBar) desktopNavBar,
              Expanded(
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: const BouncingScrollPhysics(),
                      children: _buildPages(isAuthed),
                    ),
                    // Mobile logo bar - only shown on mobile
                    if (!isWideScreen)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: mobileLogoBar,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: isWideScreen
            ? const SizedBox(
                key: ValueKey('mobile-nav-hidden'),
              )
            : SizedBox(
                key: const ValueKey('mobile-nav'),
                height: 70,
                child: mobileNavBar,
              ),
      ),
    );
  }

  Widget _buildLogoContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.hasBoundedHeight && constraints.maxHeight.isFinite ? constraints.maxHeight : 70.0;
        final logoSize = (maxHeight * 0.55).clamp(20.0, 40.0);
        final textSize = (maxHeight * 0.28).clamp(14.0, 22.0);
        final gapSize = (maxHeight * 0.12).clamp(6.0, 12.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              _logoAssetPath,
              height: logoSize,
              width: logoSize,
            ),
            SizedBox(width: gapSize),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD700), // Bright gold
                  Color(0xFFD4A84B), // Medium gold
                  Color(0xFFB8860B), // Dark gold
                  Color(0xFFD4A84B), // Medium gold
                  Color(0xFFFFD700), // Bright gold
                ],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ).createShader(bounds),
              child: Text(
                'GoldMap',
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoBox() {
    return SizedBox(
      width: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: _buildLogoContent(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _desktopFlashController,
                builder: (context, _) {
                  final opacity = _desktopFlashOpacity.value;
                  if (opacity <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Opacity(
                      opacity: opacity * 0.6,
                      child: Container(
                        width: 3,
                        color: const Color(0xFFD4A84B).withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSquareButtons({required bool isAuthed, bool showLabels = false}) {
    final items = [
      {'icon': Icons.show_chart_rounded, 'label': 'Markets', 'index': 0},
      {'icon': Icons.map_rounded, 'label': 'Map', 'index': 1},
      {'icon': Icons.currency_exchange_rounded, 'label': 'Trade', 'index': 2},
      {'icon': Icons.event_rounded, 'label': 'Events', 'index': 3},
      {
        'icon': isAuthed ? Icons.person_rounded : Icons.person_add_rounded,
        'label': isAuthed ? 'Profile' : 'Sign Up',
        'index': 4,
      },
      {
        'icon': isAuthed ? Icons.chat_bubble_rounded : Icons.settings_rounded,
        'label': isAuthed ? 'Messages' : 'Settings',
        'index': 5,
      },
    ];
    final isDark = ref.watch(themeProvider);

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = _selectedIndex == item['index'];
      final navIndex = item['index']! as int;
      final isFirst = index == 0;
      final isLast = index == items.length - 1;

      final iconColor = isSelected
          ? const Color(0xFFD4A84B)
          : isDark
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.5);

      return Flexible(
        flex: 2,
        child: GestureDetector(
          onTap: () => _onNavTap(navIndex),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05))
                  : Colors.transparent,
              border: Border(
                left: !isFirst && isSelected
                    ? BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                        width: 0.5,
                      )
                    : BorderSide.none,
                right: !isLast && isSelected
                    ? BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                        width: 0.5,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: showLabels
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon']! as IconData,
                          color: iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['label']! as String,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      item['icon']! as IconData,
                      color: iconColor,
                      size: 24,
                    ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildPages(bool isAuthed) {
    return [
      const MarketsPage(), // 0 - Chart
      const MapPage(), // 1 - Map
      const TradePage(), // 2 - Buy/Sell
      const EventsPage(), // 3 - Events
      if (isAuthed) const ProfilePage() else const SignUpPage(), // 4 - Profile / Sign Up
      if (isAuthed) const MessagesPage() else const SettingsPage(), // 5 - Messages / Settings
    ];
  }
}
