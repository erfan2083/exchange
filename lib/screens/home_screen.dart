import 'package:flutter/material.dart';
import 'package:exchange/models/crypto_price.dart';
import 'package:exchange/services/nobitex_api.dart';
import 'package:exchange/widgets/crypto_card.dart';
import 'package:exchange/screens/order_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../models/wallet.dart';
import 'active_orders_screen.dart';
import 'coin_detail_screen.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CryptoPrice> prices = [];
  bool isLoading = false;
  List<Wallet> wallets = [];

  Future<void> loadPrices() async {
    setState(() => isLoading = true);
    prices = await NobitexApi.fetchPrices();
    setState(() => isLoading = false);
  }

  Future<void> loadWallet() async {
    setState(() => isLoading = true);
    wallets = await NobitexApi.fetchWallets();
    setState(() => isLoading = false);
  }


  @override
  void initState() {
    super.initState();
    loadPrices();
    loadWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF121330), // top color
            Color(0xFF3E1E68), // bottom color
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Deep navy background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('My Crypto Wallet'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen(),
                  ),
                );
              }
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Wallet Card
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9A1B43), Color(0xFF3E1E68)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${wallets.isEmpty? '\$0' : '\$' + (double.parse(wallets[0].balance) / prices[3].buyPrice as String)}',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 8),
                          Text('${wallets.isEmpty? '0 Rial' : wallets[0].balance + ' Rial'}',
                              style: TextStyle(color: Colors.white70, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('USDT Price: ' + '${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(prices[3].buyPrice)} Rial',
                              style: TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                    ),
              ),

              const SizedBox(height: 24),

              // Highlight coins
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _highlightCoinTile(prices[0].symbol.split('-')[0], NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(prices[0].buyPrice), Colors.deepPurple),
                  _highlightCoinTile(prices[1].symbol.split('-')[0], NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(prices[1].buyPrice), Colors.green),
                  _highlightCoinTile(prices[4].symbol.split('-')[0], NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(prices[4].buyPrice), Colors.purple),
                ],
              ),

              const SizedBox(height: 24),

              // Portfolio list
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox( // استفاده از SizedBox به جای Expanded
                  height: MediaQuery.of(context).size.height * 0.5, // مثلاً 60٪ ارتفاع صفحه
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : prices.isEmpty
                      ? const Center(child: Text("No data available"))
                      : ListView.builder(
                    itemCount: prices.length,
                    itemBuilder: (context, index) {
                      final coin = prices[index];
                      final srcCurrency = coin.symbol.split('-')[0]; // میشه: btc
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black87,
                          child: Text('${coin.symbol.split('-')[0]}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        title: Text('${coin.symbol.split('-')[0]}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text(
                            '${NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0).format(coin.buyPrice)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CoinDetailScreen(symbol: srcCurrency.toLowerCase()),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            loadPrices();
            loadWallet();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

Widget _highlightCoinTile(String symbol, String price, Color color) {
  return Container(
    width: 100,
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1D1E3D),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Color(0xFF121330)
      )

    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 12,
          child: Text(
            symbol[0],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Text(symbol,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(color: Colors.white70, fontSize: 12)),

      ],
    ),
  );
}
