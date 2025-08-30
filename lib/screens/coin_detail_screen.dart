import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String selectedInterval = "D"; // Default interval


  final amountController = TextEditingController();
  final priceController = TextEditingController();

  Future<void> _handleOrder(String type) async {
    try {
      final balances = await NobitexApi.getBalances();
      final srcCurrency = widget.symbol.toLowerCase();
      final double amount = double.tryParse(amountController.text) ?? 0;
      final double price = double.tryParse(priceController.text) ?? 0;

      if (amount <= 0 || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter valid amount and price")),
        );
        return;
      }

      if (type == "buy") {
        double totalCost = amount * price;
        double availableIRT = balances["irt"] ?? 0;
        if (availableIRT < totalCost) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Not enough IRT balance")),
          );
          return;
        }
      } else if (type == "sell") {
        double availableCoin = balances[srcCurrency] ?? 0;
        if (availableCoin < amount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Not enough $srcCurrency balance")),
          );
          return;
        }
      }

      final message = await NobitexApi.placeOrder(
        type: type,
        symbol: "${widget.symbol.toUpperCase()}IRT",
        amount: amount,
        price: price,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }



  @override
  void initState() {
    super.initState();
    futureStats = NobitexApi.fetchCoinStats(widget.symbol);
    futureOhlc = NobitexApi.fetchOhlcData(widget.symbol, resolution: selectedInterval);
  }

  void _updateInterval(String interval) {
    setState(() {
      selectedInterval = interval;
      futureOhlc = NobitexApi.fetchOhlcData(widget.symbol, resolution: selectedInterval);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF121330), Color(0xFF3E1E68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.symbol.toUpperCase()} / IRT', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
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
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    /// ===== BEAUTIFUL PRICE SECTION =====
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1F4A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.latest),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _priceInfo("High", coin.dayHigh),
                              _priceInfo("Low", coin.dayLow),
                              _priceInfo("Change", 0, change: coin.dayChange, isChange: true),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ===== CHART SECTION =====
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1F4A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          /// Interval selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: ["15", "60", "D"].map((interval) {
                              return ChoiceChip(
                                label: Text(
                                  interval,
                                  style: TextStyle(
                                    color: selectedInterval == interval ? Colors.black : Colors.white,
                                  ),
                                ),
                                selected: selectedInterval == interval,
                                selectedColor: Colors.greenAccent,
                                backgroundColor: Colors.transparent,
                                onSelected: (_) => _updateInterval(interval),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),

                          /// Chart
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
                                    labelStyle: const TextStyle(color: Colors.white70),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    opposedPosition: true,
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

                    const SizedBox(height: 20),

                    /// ===== BUY / SELL ORDER SECTION =====
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1F4A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text("Place Order", style: TextStyle(fontSize: 18, color: Colors.white)),
                          const SizedBox(height: 10),
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: "Amount",
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: const Color(0xFF2C2F5A),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: "Price",
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: const Color(0xFF2C2F5A),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _handleOrder("buy"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                                  child: const Text("Buy", style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _handleOrder("sell"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  child: const Text("Sell", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _priceInfo(String label, int value, {bool isChange = false, double change = 0.00}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          isChange ? "${change.toStringAsFixed(2)}%" : NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isChange
                ? (change >= 0 ? Colors.greenAccent : Colors.redAccent)
                : Colors.white,
          ),
        ),
      ],
    );
  }
}
