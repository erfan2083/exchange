import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/candle_data.dart';

class PriceChart extends StatelessWidget {
  final List<CandleData> candles;

  const PriceChart({super.key, required this.candles});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = candles.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.deepPurple,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }
}
