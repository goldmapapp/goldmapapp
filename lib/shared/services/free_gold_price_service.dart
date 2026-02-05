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
  static const String _stooqBaseUrl = 'https://stooq.com';

  /// Prefer moving to env (e.g. --dart-define=FREEGOLDPRICE_API_KEY=...) for production.
  static const String _apiKey = '4x6Jg9Kfz1MqhMGXuFd4nGPmrLoWg0SguL1q5Nnu9ru1oDbdy8rHxqHxNfLF';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  final Dio _historyDio = Dio(
    BaseOptions(
      baseUrl: _stooqBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
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

  /// Real historical prices from Stooq, filtered to selected range.
  ///
  /// FreeGoldPrice's public API docs expose current prices, but not timeseries.
  /// For charting ranges (1D..5Y), we fetch a long USD series and slice it.
  Future<List<PriceDataPoint>> getHistoricalPrices({
    required MetalType metal,
    required DateTime start,
    required DateTime end,
  }) async {
    if (!end.isAfter(start)) return const [];

    final symbol = metal == MetalType.gold ? 'xauusd' : 'xagusd';
    final response = await _historyDio.get<String>(
      '/q/d/l/',
      queryParameters: {'s': symbol, 'i': 'd'},
      options: Options(responseType: ResponseType.plain),
    );

    if (response.statusCode != 200 || response.data == null || response.data!.isEmpty) {
      throw Exception('Unable to load historical data');
    }

    final parsed = _parseStooqCsv(response.data!, start, end);
    return _downsample(parsed, _targetPointsForRange(start, end));
  }

  List<PriceDataPoint> _parseStooqCsv(String csv, DateTime start, DateTime end) {
    final lines = csv.split('\n');
    if (lines.length < 2) return const [];

    final points = <PriceDataPoint>[];
    for (final line in lines.skip(1)) {
      final row = line.trim();
      if (row.isEmpty) continue;
      final columns = row.split(',');
      if (columns.length < 5) continue;

      final timestamp = DateTime.tryParse(columns[0]);
      final close = double.tryParse(columns[4]);
      if (timestamp == null || close == null || !close.isFinite || close <= 0) {
        continue;
      }

      if (timestamp.isBefore(start) || timestamp.isAfter(end)) {
        continue;
      }

      points.add(PriceDataPoint(timestamp: timestamp, price: close));
    }

    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return points;
  }

  int _targetPointsForRange(DateTime start, DateTime end) {
    final totalHours = end.difference(start).inHours;
    if (totalHours <= 24) return 96;
    if (totalHours <= 168) return 168;
    if (totalHours <= 720) return 120;
    if (totalHours <= 2160) return 180;
    if (totalHours <= 8760) return 365;
    return 260;
  }

  List<PriceDataPoint> _downsample(List<PriceDataPoint> points, int maxPoints) {
    if (points.length <= maxPoints || maxPoints < 2) return points;

    final result = <PriceDataPoint>[points.first];
    final step = (points.length - 1) / (maxPoints - 1);

    for (var i = 1; i < maxPoints - 1; i++) {
      final index = (i * step).round();
      result.add(points[index.clamp(1, points.length - 2)]);
    }

    result.add(points.last);
    return result;
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
