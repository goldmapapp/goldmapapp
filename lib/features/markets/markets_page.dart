import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/widgets/glass_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_win_floating/webview_win_floating.dart';

class MarketsPage extends ConsumerStatefulWidget {
  const MarketsPage({super.key});

  @override
  ConsumerState<MarketsPage> createState() => _MarketsPageState();
}

class _MarketsPageState extends ConsumerState<MarketsPage> {
  static const _goldSymbol = 'OANDA:XAUUSD';
  static const _tradingViewHost = 'https://www.tradingview.com';

  WinWebViewController? _controller;
  bool? _lastIsDark;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isWindows) {
      _controller = WinWebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted);
      _lastIsDark = ref.read(themeProvider);
      _loadChartHtml(isDark: _lastIsDark ?? false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _loadChartHtml({required bool isDark}) {
    _controller?.loadHtmlString(
      _buildTradingViewHtml(
        symbol: _goldSymbol,
        isDark: isDark,
      ),
    );
  }

  String _buildTradingViewHtml({
    required String symbol,
    required bool isDark,
  }) {
    final theme = isDark ? 'dark' : 'light';
    // Match app gradient background colors
    final bgColor = isDark ? '#454545' : '#F0F0F2';
    final gridColor = isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)';
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body, .container, div {
      margin: 0; padding: 0; width: 100%; height: 100%;
      background: $bgColor !important;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="tradingview-widget-container" style="height:100%;width:100%">
      <div class="tradingview-widget-container__widget" style="height:100%;width:100%"></div>
      <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js" async>
      {
        "autosize": true,
        "symbol": "$symbol",
        "interval": "D",
        "timezone": "exchange",
        "theme": "$theme",
        "backgroundColor": "$bgColor",
        "gridColor": "$gridColor",
        "style": "1",
        "locale": "en",
        "allow_symbol_change": false,
        "calendar": false,
        "support_host": "$_tradingViewHost",
        "withdateranges": true,
        "save_image": false,
        "details": true,
        "hotlist": false,
        "hide_side_toolbar": false
      }
      </script>
    </div>
  </div>
</body>
</html>
''';
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse('$_tradingViewHost/symbols/$_goldSymbol/');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    if (_lastIsDark != isDark && _controller != null) {
      _lastIsDark = isDark;
      _loadChartHtml(isDark: isDark);
    }

    final fallback = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'WebView not available on this platform',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _openInBrowser,
            child: const Text('Open Chart in Browser'),
          ),
        ],
      ),
    );

    final isWindows = !kIsWeb && Platform.isWindows;
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    // Extra top padding on mobile for the logo bar overlay
    final topPadding = isWideScreen ? 16.0 : 86.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: isWindows && _controller != null
            ? WinWebViewWidget(controller: _controller!)
            : fallback,
      ),
    );
  }
}
