import 'package:flutter/material.dart';
import 'package:exchange/models/portfolio_item.dart';
import 'package:exchange/services/nobitex_api.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final List<PortfolioItem> portfolio = [
    PortfolioItem(symbol: 'btc-rls', amount: 0.04),
    PortfolioItem(symbol: 'eth-rls', amount: 0.5),
    PortfolioItem(symbol: 'usdt-rls', amount: 300),
  ];

  Map<String, dynamic> prices = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  Future<void> loadPrices() async {
    try {
      final data = await NobitexApi.fetchMarketStats(
        symbols: portfolio.map((e) => e.symbol).toList(),
      );
      setState(() {
        prices = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading prices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;

    for (var item in portfolio) {
      final price = double.tryParse(prices[item.symbol]?['latest'] ?? '0') ?? 0;
      total += price * item.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('سبد دارایی'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('ارزش کل دارایی', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '${total.toStringAsFixed(0)} ریال',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: portfolio.length,
              itemBuilder: (context, index) {
                final item = portfolio[index];
                final price = double.tryParse(prices[item.symbol]?['latest'] ?? '0') ?? 0;
                final value = price * item.amount;

                return ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded),
                  title: Text(item.symbol.toUpperCase()),
                  subtitle: Text('${item.amount} واحد'),
                  trailing: Text('${value.toStringAsFixed(0)} ریال'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
