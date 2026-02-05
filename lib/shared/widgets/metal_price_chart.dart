import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldmapapp/shared/models/metal_price.dart';
import 'package:goldmapapp/shared/providers/metal_price_provider.dart';
import 'package:goldmapapp/shared/providers/theme_provider.dart';
import 'package:goldmapapp/shared/services/free_gold_price_service.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

class MetalPriceChart extends ConsumerWidget {
  const MetalPriceChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMetal = ref.watch(selectedMetalProvider);
    final selectedTimeRange = ref.watch(selectedTimeRangeProvider);
    final currentPriceAsync = ref.watch(currentPriceProvider);
    final historicalDataAsync = ref.watch(historicalDataProvider);
    final isDark = ref.watch(themeProvider);

    final isGold = selectedMetal == MetalType.gold;
    final primaryColor = isGold ? const Color(0xFFFFD700) : const Color(0xFFC0C0C0);

    return Column(
      children: [
        // Header
        _buildHeader(context, ref, currentPriceAsync, isGold, primaryColor),

        // Time Range Selector
        _buildTimeRangeSelector(ref, primaryColor),

        // Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: historicalDataAsync.when(
              data: (data) => _buildChart(ref, data, selectedTimeRange, primaryColor),
              loading: () => Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, AsyncValue<MetalPrice> priceAsync, bool isGold, Color color) {
    final isDark = ref.watch(themeProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
        ),
      ),
      child: Stack(
        children: [
          // Price Display
          Center(
            child: priceAsync.when(
              data: (price) => Column(
                children: [
                  Text(
                    isGold ? 'GOLD' : 'SILVER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'H \$${price.high.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'L \$${price.low.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => CircularProgressIndicator(color: color),
              error: (e, _) => Text('Error: $e', style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
          ),
          // Metal Toggle
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMetalButton(
                    'Au',
                    isGold,
                    const Color(0xFFFFD700),
                    () => ref.read(selectedMetalProvider.notifier).state = MetalType.gold,
                    isDark,
                  ),
                  _buildMetalButton(
                    'Ag',
                    !isGold,
                    const Color(0xFFC0C0C0),
                    () => ref.read(selectedMetalProvider.notifier).state = MetalType.silver,
                    isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalButton(String symbol, bool isSelected, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          symbol,
          style: TextStyle(
            color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white : Colors.grey),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(WidgetRef ref, Color primaryColor) {
    final selected = ref.watch(selectedTimeRangeProvider);
    final isDark = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: TimeRange.values.map((range) {
            final isSelected = range == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => ref.read(selectedTimeRangeProvider.notifier).state = range,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    range.label,
                    style: TextStyle(
                      color: isDark ? Colors.white : (isSelected ? Colors.black : Colors.grey[700]),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChart(WidgetRef ref, List<PriceDataPoint> data, TimeRange timeRange, Color color) {
    final isDark = ref.watch(themeProvider);
    if (data.isEmpty || data.length < 2) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      );
    }

    try {
      // Sanitize: ensure no NaN/infinite so graphic package tooltip never gets invalid RRect
      final chartData = data
          .where((p) => p.price.isFinite && p.price > 0)
          .map(
            (point) => {
              'time': point.timestamp,
              'price': point.price,
            },
          )
          .toList();

      if (chartData.length < 2) {
        return Center(
          child: Text(
            'Not enough valid data',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        );
      }

      return Chart(
        data: chartData,
        variables: {
          'time': Variable(
            accessor: (Map<dynamic, dynamic> map) => map['time'] as DateTime,
            scale: TimeScale(
              marginMin: 0,
              marginMax: 0,
              formatter: (DateTime time) {
                switch (timeRange) {
                  case TimeRange.day:
                    return DateFormat('HH:mm').format(time);
                  case TimeRange.week:
                    return DateFormat('EEE').format(time);
                  case TimeRange.month:
                  case TimeRange.threeMonths:
                    return DateFormat('MMM d').format(time);
                  case TimeRange.year:
                    return DateFormat('MMM').format(time);
                  case TimeRange.fiveYears:
                    return DateFormat('yyyy').format(time);
                }
              },
            ),
          ),
          'price': Variable(
            accessor: (Map<dynamic, dynamic> map) => map['price'] as num,
            scale: LinearScale(
              marginMin: 0,
              marginMax: 0,
              formatter: (num price) => price.round().toString(),
            ),
          ),
        },
        marks: [
          // Position (X, Y): first = horizontal/bottom = time, second = vertical/left = price.
          AreaMark(
            position: Varset('time') * Varset('price'),
            color: ColorEncode(
              value: color.withValues(alpha: 0.15),
            ),
            shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
          ),
          LineMark(
            position: Varset('time') * Varset('price'),
            size: SizeEncode(value: 2),
            color: ColorEncode(value: color),
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
          ),
        ],
        axes: [
          Defaults.horizontalAxis
            ..label = LabelStyle(
              textStyle: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54,
              ),
            )
            ..grid = null,
          Defaults.verticalAxis
            ..label = LabelStyle(
              textStyle: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54,
              ),
            )
            ..grid = PaintStyle(
              strokeColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!,
            ),
        ],
        padding: (_) => const EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 30),
        selections: {
          'touchMove': PointSelection(
            on: {
              GestureType.hover,
              GestureType.tapDown,
            },
            dim: Dim.x,
          ),
        },
        crosshair: CrosshairGuide(
          styles: [
            PaintStyle(strokeColor: color.withValues(alpha: 0.5)),
            PaintStyle(strokeColor: color.withValues(alpha: 0.5)),
          ],
        ),
      );
    } catch (e) {
      return Center(
        child: Text(
          'Chart error: $e',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      );
    }
  }
}
