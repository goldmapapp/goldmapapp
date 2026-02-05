import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/models/metal_price.dart';
import 'package:goldmapapp/shared/services/free_gold_price_service.dart';

final metalPriceServiceProvider = Provider<FreeGoldPriceService>((ref) {
  return FreeGoldPriceService();
});

enum TimeRange {
  day('1D', Duration(hours: 24)),
  week('1W', Duration(days: 7)),
  month('1M', Duration(days: 30)),
  threeMonths('3M', Duration(days: 90)),
  year('1Y', Duration(days: 365)),
  fiveYears('5Y', Duration(days: 1825));

  final String label;
  final Duration duration;
  const TimeRange(this.label, this.duration);
}

final selectedMetalProvider = StateProvider<MetalType>((ref) => MetalType.gold);
final selectedTimeRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.day);

/// Fetched once per app load. No autoDispose so it never resets on tab/timeframe change.
final pricesCacheProvider = FutureProvider<FreeGoldPriceResponse>((ref) {
  final service = ref.watch(metalPriceServiceProvider);
  return service.getPrices();
});

/// Current price for the selected metal. Reads from cache only — no extra polling.
final currentPriceProvider = Provider<AsyncValue<MetalPrice>>((ref) {
  final cache = ref.watch(pricesCacheProvider);
  final metal = ref.watch(selectedMetalProvider);
  return cache.when(
    data: (r) {
      if (metal == MetalType.gold) {
        return AsyncValue.data(
          MetalPrice.fromFreeGoldPrice(
            metal: metal.displayName,
            ask: r.goldAsk,
            bid: r.goldBid,
          ),
        );
      }
      return AsyncValue.data(
        MetalPrice.fromFreeGoldPrice(
          metal: metal.displayName,
          ask: r.silverAsk,
          bid: r.silverBid,
        ),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

/// Historical chart data.
///
/// Tries real timeseries first; falls back to generated placeholder when unavailable.
final historicalDataProvider = FutureProvider<List<PriceDataPoint>>((ref) async {
  final cache = ref.watch(pricesCacheProvider);
  final metal = ref.watch(selectedMetalProvider);
  final timeRange = ref.watch(selectedTimeRangeProvider);
  final service = ref.read(metalPriceServiceProvider);

  final r = await cache.future;
  final price = metal == MetalType.gold ? r.goldMid : r.silverMid;
  final start = DateTime.now().subtract(timeRange.duration);
  final end = DateTime.now();

  try {
    final history = await service.getHistoricalPrices(metal: metal, start: start, end: end);
    if (history.length >= 2) {
      return history;
    }
  } catch (_) {
    // Use placeholder fallback below.
  }

  return service.buildHistoricalPlaceholder(price, start, end);
});
