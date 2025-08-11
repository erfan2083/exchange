import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/coin_stats.dart';
import '../models/ohlc_data.dart';
import '../services/nobitex_api.dart';

class CoinDetailScreen extends StatefulWidget {
  final String symbol;

  const CoinDetailScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  late Future<CoinStats> futureStats;
  late Future<List<OhlcData>> futureOhlc;

  @override
  void initState() {
    super.initState();
    futureStats = NobitexApi.fetchCoinStats(widget.symbol);
    futureOhlc = NobitexApi.fetchOhlcData(widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF121330), // top
            Color(0xFF3E1E68), // bottom
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.symbol.toUpperCase()} / IRT'),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: FutureBuilder<CoinStats>(
          future: futureStats,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final coin = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ====== PRICE INFO ======
                  Text(
                    'Current Price: ${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.latest)} Rials',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Buy: ${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.bestBuy)} | Sell: ${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.bestSell)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'High: ${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.dayHigh)} | Low: ${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.dayLow)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Change: ${coin.dayChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: coin.dayChange >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ====== CHART SECTION ======
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1F4A), // Lighter dark background
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price Chart",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),

                        FutureBuilder<List<OhlcData>>(
                          future: futureOhlc,
                          builder: (context, chartSnap) {
                            if (chartSnap.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (chartSnap.hasError) {
                              return Text('Chart Error: ${chartSnap.error}', style: const TextStyle(color: Colors.redAccent));
                            }
                            final ohlcList = chartSnap.data!;
                            return SizedBox(
                              height: 300,
                              child: SfCartesianChart(
                                plotAreaBackgroundColor: Colors.transparent,
                                zoomPanBehavior: ZoomPanBehavior(
                                  enablePanning: true,
                                  enablePinching: true,
                                  zoomMode: ZoomMode.x,
                                ),
                                primaryXAxis: DateTimeAxis(
                                  majorGridLines: const MajorGridLines(width: 0),
                                  axisLine: const AxisLine(width: 0),
                                  labelStyle: const TextStyle(color: Colors.white70),
                                ),
                                primaryYAxis: NumericAxis(
                                  opposedPosition: true,
                                  majorGridLines: const MajorGridLines(color: Colors.white12),
                                  labelStyle: const TextStyle(color: Colors.white70),
                                ),
                                series: <CandleSeries>[
                                  CandleSeries<OhlcData, DateTime>(
                                    dataSource: ohlcList,
                                    xValueMapper: (OhlcData data, _) => data.time,
                                    lowValueMapper: (OhlcData data, _) => data.low,
                                    highValueMapper: (OhlcData data, _) => data.high,
                                    openValueMapper: (OhlcData data, _) => data.open,
                                    closeValueMapper: (OhlcData data, _) => data.close,
                                    bullColor: Colors.greenAccent,
                                    bearColor: Colors.redAccent,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// ====== BUY / SELL BUTTONS ======
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Buy'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            foregroundColor: Colors.redAccent,
                          ),
                          child: const Text('Sell'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
