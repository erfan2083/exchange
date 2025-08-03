import 'package:flutter/material.dart';
import 'package:exchange/models/crypto_price.dart';
import 'package:exchange/services/nobitex_api.dart';
import 'package:exchange/widgets/crypto_card.dart';
import 'package:exchange/screens/order_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'active_orders_screen.dart';
import 'coin_detail_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CryptoPrice> prices = [];
  bool isLoading = false;

  Future<void> loadPrices() async {
    setState(() => isLoading = true);
    prices = await NobitexApi.fetchPrices();
    setState(() => isLoading = false);
  }

  Future<void> showWalletDialog() async {
    final wallets = await NobitexApi.fetchWallets();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💰 Your Wallet'),
        content: SizedBox(
          width: double.maxFinite,
          child: wallets.isEmpty
              ? const Text("No non-zero assets found.")
              : ListView.builder(
            shrinkWrap: true,
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final w = wallets[index];
              return ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(w.currency.toUpperCase()),
                subtitle: Text('Balance: ${w.balance}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('💹 Nobitex Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadPrices,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: showWalletDialog,
                icon: const Icon(Icons.wallet),
                label: const Text('My Wallet'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderScreen()),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('New Order'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveOrdersScreen()));
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Active Orders'),
              ),

            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : prices.isEmpty
                ? const Center(child: Text("No data available"))
                : ListView.builder(
              itemCount: prices.length,
              itemBuilder: (context, index) {
                final coin = prices[index];
                final srcCurrency =coin.symbol.split('-')[0]; // میشه: btc
                return ListTile(
                  title: Text('${coin.symbol}'),
                  subtitle: Text('${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.buyPrice)} IRT'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoinDetailScreen(symbol: srcCurrency.toLowerCase()),
                      ),
                    );
                  },
                );
              },
            )
          ),
        ],
      ),
    );
  }
}
