import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'شما هیچ سفارشی ندارید',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
