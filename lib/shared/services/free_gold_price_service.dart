import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:goldmapapp/shared/models/metal_price.dart';

/// FreeGoldPrice.org API (https://freegoldprice.org/docs/shortcode).
/// V2 GSJ = Gold & Silver JSON per ounce, 1 credit per request.
/// No historical endpoint — we use current prices and generate chart placeholder.
enum MetalType {
  gold('XAU', 'Gold'),
  silver('XAG', 'Silver');

  final String symbol;
  final String displayName;
  const MetalType(this.symbol, this.displayName);
}

/// Raw response from GET .../api/v2?key=...&action=GSJ
class FreeGoldPriceResponse {
  const FreeGoldPriceResponse({
    required this.date,
    required this.goldAsk,
    required this.goldBid,
    required this.silverAsk,
    required this.silverBid,
  });
  final String date;
  final double goldAsk;
  final double goldBid;
  final double silverAsk;
  final double silverBid;

  double get goldMid => (goldAsk + goldBid) / 2;
  double get silverMid => (silverAsk + silverBid) / 2;
}

class FreeGoldPriceService {
  static const String _baseUrl = 'https://freegoldprice.org';

  /// Prefer moving to env (e.g. --dart-define=FREEGOLDPRICE_API_KEY=...) for production.
  static const String _apiKey = '4x6Jg9Kfz1MqhMGXuFd4nGPmrLoWg0SguL1q5Nnu9ru1oDbdy8rHxqHxNfLF';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Single call: Gold & Silver per ounce (JSON). Use once per app load.
  /// Throws on non-200 or missing/invalid price data so UI shows error instead of $0.00.
  Future<FreeGoldPriceResponse> getPrices() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v2',
      queryParameters: {'key': _apiKey, 'action': 'GSJ'},
    );

    if (response.statusCode != 200) {
      final msg = response.data is Map
          ? (response.data as Map)['message'] ?? response.data.toString()
          : response.statusMessage ?? 'HTTP ${response.statusCode}';
      throw Exception('API error: $msg');
    }

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('API returned invalid data');
    }

    // API nests everything under "GSJ" key with capitalized metal names
    final gsj = data['GSJ'] as Map<String, dynamic>? ?? data;
    final date = gsj['date'] as String? ?? DateTime.now().toIso8601String();
    final gold = gsj['Gold'] as Map<String, dynamic>? ?? {};
    final silver = gsj['Silver'] as Map<String, dynamic>? ?? {};
    final goldUsd = gold['USD'] as Map<String, dynamic>? ?? {};
    final silverUsd = silver['USD'] as Map<String, dynamic>? ?? {};

    final goldAsk = _parsePrice(goldUsd['ask'], 'gold ask');
    final goldBid = _parsePrice(goldUsd['bid'], 'gold bid');
    final silverAsk = _parsePrice(silverUsd['ask'], 'silver ask');
    final silverBid = _parsePrice(silverUsd['bid'], 'silver bid');

    if (goldAsk <= 0 || goldBid <= 0 || silverAsk <= 0 || silverBid <= 0) {
      throw Exception(
        'API returned invalid prices (check key/credits). '
        'Gold: $goldAsk/$goldBid, Silver: $silverAsk/$silverBid',
      );
    }

    return FreeGoldPriceResponse(
      date: date,
      goldAsk: goldAsk,
      goldBid: goldBid,
      silverAsk: silverAsk,
      silverBid: silverBid,
    );
  }

  /// Parse ask/bid from JSON (may be num or string).
  double _parsePrice(dynamic value, String label) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Build chart series from current price only (no history API). Smooth placeholder.
  List<PriceDataPoint> buildHistoricalPlaceholder(
    double currentPrice,
    DateTime start,
    DateTime end,
  ) {
    if (!currentPrice.isFinite || currentPrice <= 0) {
      currentPrice = 2000; // fallback so chart/tooltip never see NaN or zero
    }
    final points = <PriceDataPoint>[];
    final duration = end.difference(start);
    final totalHours = duration.inHours;

    int targetDataPoints;
    if (totalHours <= 24) {
      targetDataPoints = 96;
    } else if (totalHours <= 168) {
      targetDataPoints = 168;
    } else if (totalHours <= 720) {
      targetDataPoints = 120;
    } else if (totalHours <= 2160) {
      targetDataPoints = 180;
    } else if (totalHours <= 8760) {
      targetDataPoints = 365;
    } else {
      targetDataPoints = 260;
    }

    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    var price = currentPrice * 0.997;

    for (var i = 0; i <= targetDataPoints; i++) {
      final t = i / targetDataPoints;
      final timestamp = start.add(
        Duration(milliseconds: (duration.inMilliseconds * t).round()),
      );
      final drift = (currentPrice - price) / (targetDataPoints - i).clamp(1, targetDataPoints);
      final volatility = currentPrice * 0.0002;
      final smoothNoise = _smoothNoise(i, random) * volatility;
      price = price + drift + smoothNoise;
      price = price.clamp(currentPrice * 0.98, currentPrice * 1.02);
      points.add(PriceDataPoint(timestamp: timestamp, price: price));
    }

    if (points.isNotEmpty) {
      points[points.length - 1] = PriceDataPoint(timestamp: end, price: currentPrice);
    }
    return points;
  }

  double _smoothNoise(int i, int seed) {
    final phase = (seed % 100) / 100.0 * 6.28;
    return math.sin(i * 0.02 + phase) * 0.5;
  }
}
