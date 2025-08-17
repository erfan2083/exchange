import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import '../models/crypto_price.dart';

class AssetsScreen extends StatelessWidget {
  final List<Wallet> wallets;
  final List<CryptoPrice> prices;

  const AssetsScreen({Key? key, required this.wallets, required this.prices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // محاسبه کل دارایی
    double totalValue = 0;
    final List<Map<String, dynamic>> assetsData = [];

    for (var w in wallets) {
      final match = prices.firstWhere(
            (p) => p.symbol.split('-')[0].toLowerCase() == w.currency.toLowerCase(),
        orElse: () => CryptoPrice(symbol: "${w.currency}-IRT", buyPrice: 0, sellPrice: 0),
      );
      double value = double.tryParse(w.balance) != null
          ? double.parse(w.balance) * match.buyPrice
          : 0;
      totalValue += value;

      assetsData.add({
        "symbol": w.currency.toUpperCase(),
        "amount": double.tryParse(w.balance) ?? 0,
        "value": value,
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Assets"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF121330),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Pie Chart بخش بالا
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: assetsData.map((asset) {
                    final percent = totalValue == 0 ? 0 : asset["value"] / totalValue * 100;
                    return PieChartSectionData(
                      title: "${percent.toStringAsFixed(1)}%",
                      color: Colors.primaries[assetsData.indexOf(asset) % Colors.primaries.length],
                      value: asset["value"],
                      radius: 80,
                      titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList(),
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Total Value: ${NumberFormat.currency(locale: "en_US", symbol: "", decimalDigits: 0).format(totalValue)} Rial",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            /// لیست کوین‌ها
            Expanded(
              child: ListView.builder(
                itemCount: assetsData.length,
                itemBuilder: (context, index) {
                  final asset = assetsData[index];
                  return Card(
                    color: const Color(0xFF1D1F4A),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.primaries[index % Colors.primaries.length],
                        child: Text(asset["symbol"][0], style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(asset["symbol"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "${asset["amount"]} ${asset["symbol"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        "${NumberFormat.currency(locale: "en_US", symbol: "", decimalDigits: 0).format(asset["value"])} Rial",
                        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
