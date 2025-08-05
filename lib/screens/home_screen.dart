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


  @override
  void initState() {
    super.initState();
    loadPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121330), // Deep navy background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Crypto Wallet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Wallet Card
            Container(
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
                children: const [
                  Text('\$7,556',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  Text('214,198,634 Toman',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('USDT Price: 28,349 Toman',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Highlight coins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _highlightCoinTile('BTC', '\$41,944', Colors.deepPurple),
                _highlightCoinTile('ETH', '\$2,884', Colors.green),
                _highlightCoinTile('BCH', '\$298', Colors.purple),
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
                height: MediaQuery.of(context).size.height * 0.6, // مثلاً 60٪ ارتفاع صفحه
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
          // Reload logic
        },
        child: const Icon(Icons.refresh),
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

class _assetRow extends StatelessWidget {
  final String symbol;
  final String amount;
  final String value;

  const _assetRow(this.symbol, this.amount, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.black87,
        child: Text(symbol,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
      title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(amount),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
