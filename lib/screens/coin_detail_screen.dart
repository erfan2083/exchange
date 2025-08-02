import 'package:flutter/material.dart';
import '../models/coin_stats.dart';
import '../services/nobitex_api.dart';

class CoinDetailScreen extends StatefulWidget {
  final String symbol;

  const CoinDetailScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  late Future<CoinStats> futureStats;

  @override
  void initState() {
    super.initState();
    futureStats = NobitexApi.fetchCoinStats(widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.symbol.toUpperCase()} / IRT')),
      body: FutureBuilder<CoinStats>(
        future: futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final coin = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Price: ${coin.latest} Rials',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Buy: ${coin.bestBuy} | Sell: ${coin.bestSell}'),
                const SizedBox(height: 10),
                Text('High: ${coin.dayHigh} | Low: ${coin.dayLow}'),
                const SizedBox(height: 10),
                Text('Change: ${coin.dayChange}%', style: TextStyle(
                    color: coin.dayChange >= 0 ? Colors.green : Colors.red
                )),
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () {}, child: Text('Buy'))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton(onPressed: () {}, child: Text('Sell'))),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
