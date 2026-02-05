class MetalPrice {
  const MetalPrice({
    required this.metal,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.timestamp,
    required this.currency,
  });

  factory MetalPrice.fromJson(Map<String, dynamic> json, String metal) {
    final priceValue = (json['price'] ?? json['Price'] ?? json['price_gram_24k'] ?? 0) as num;
    final changeValue = (json['ch'] ?? json['Ch'] ?? json['change'] ?? 0) as num;
    final changePercentValue = (json['chp'] ?? json['Chp'] ?? json['change_pct'] ?? 0) as num;
    final highValue = (json['high_24h'] ?? json['HighPrice'] ?? json['high'] ?? json['High'] ?? priceValue) as num;
    final lowValue = (json['low_24h'] ?? json['LowPrice'] ?? json['low'] ?? json['Low'] ?? priceValue) as num;

    return MetalPrice(
      metal: metal,
      price: priceValue.toDouble(),
      change: changeValue.toDouble(),
      changePercent: changePercentValue.toDouble(),
      high: highValue.toDouble(),
      low: lowValue.toDouble(),
      timestamp: DateTime.now(),
      currency: (json['currency'] ?? json['Currency'] ?? 'USD') as String,
    );
  }

  /// From FreeGoldPrice.org GSJ response (ask/bid per ounce).
  factory MetalPrice.fromFreeGoldPrice({
    required String metal,
    required double ask,
    required double bid,
  }) {
    final price = (ask + bid) / 2;
    return MetalPrice(
      metal: metal,
      price: price,
      change: 0,
      changePercent: 0,
      high: ask,
      low: bid,
      timestamp: DateTime.now(),
      currency: 'USD',
    );
  }
  final String metal;
  final double price;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final DateTime timestamp;
  final String currency;
}

class PriceDataPoint {
  const PriceDataPoint({
    required this.timestamp,
    required this.price,
  });
  final DateTime timestamp;
  final double price;
}
