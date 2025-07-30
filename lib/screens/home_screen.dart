import 'package:flutter/material.dart';
import '../services/nobitex_api.dart';
import '../widgets/crypto_card.dart';
import '../models/crypto_price.dart';

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
      appBar: AppBar(
        title: const Text('رمزارزها - نوبیتکس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadPrices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: prices.length,
        itemBuilder: (context, index) {
          return CryptoCard(price: prices[index]);
        },
      ),
    );
  }
}
