import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/widgets/glass_container.dart';

class UserSettingsPage extends ConsumerStatefulWidget {
  const UserSettingsPage({super.key});

  @override
  ConsumerState<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends ConsumerState<UserSettingsPage> {
  bool _loading = true;
  bool _messageNotifications = true;
  bool _showProfileOnMap = true;
  late TextEditingController _displayNameController;
  String? _uid;
  String? _error;
  Timer? _displayNameDebounce;
  DocumentReference<Map<String, dynamic>>? _settingsRef;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _displayNameDebounce?.cancel();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    if (isWindows) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('settings');
    setState(() {
      _uid = uid;
      _settingsRef = ref;
    });
    try {
      final snapshot = await ref.get();
      final data = snapshot.data();
      setState(() {
        _messageNotifications = data?['message_notifications'] as bool? ?? true;
        _showProfileOnMap = data?['show_profile_on_map'] as bool? ?? true;
        _displayNameController.text = data?['display_name'] as String? ?? '';
        _loading = false;
      });
    } catch (err) {
      setState(() {
        _error = 'Failed to load settings. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _saveSetting(String key, Object? value) async {
    final ref = _settingsRef;
    if (ref == null) {
      return;
    }
    try {
      await ref.set({key: value}, SetOptions(merge: true));
    } catch (_) {
      setState(() {
        _error = 'Failed to save settings. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    final topPadding = isWideScreen ? 16.0 : 86.0;
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Settings are stored per user in Firestore.',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (isWindows)
                        Text(
                          'Settings unavailable on Windows dev builds.',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black38,
                            fontSize: 16,
                          ),
                        )
                      else if (_uid == null)
                        Text(
                          'Sign in to access user settings.',
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
                              'Display name',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _displayNameController,
                              onChanged: (value) {
                                _displayNameDebounce?.cancel();
                                _displayNameDebounce = Timer(
                                  const Duration(milliseconds: 400),
                                  () => _saveSetting('display_name', value),
                                );
                              },
                              decoration: InputDecoration(
                                hintText: 'Set a public display name',
                                filled: true,
                                fillColor: isDark ? Colors.white12 : Colors.black12,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Message notifications',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              value: _messageNotifications,
                              onChanged: (value) {
                                setState(() {
                                  _messageNotifications = value;
                                });
                                _saveSetting('message_notifications', value);
                              },
                              activeThumbColor: const Color(0xFFD4A84B),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Show profile on map',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              value: _showProfileOnMap,
                              onChanged: (value) {
                                setState(() {
                                  _showProfileOnMap = value;
                                });
                                _saveSetting('show_profile_on_map', value);
                              },
                              activeThumbColor: const Color(0xFFD4A84B),
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
