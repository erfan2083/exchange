import 'package:flutter/material.dart';
import '../models/crypto_price.dart';

class CryptoCard extends StatelessWidget {
  final CryptoPrice price;

  const CryptoCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Text(price.symbol.toUpperCase()[0]),
        ),
        title: Text(price.symbol.toUpperCase()),
        subtitle: Text('Buy: ${price.buyPrice}  |  Sell: ${price.sellPrice}'),
      ),
    );
  }
}
