import 'package:flutter/material.dart';
import 'package:exchange/services/nobitex_api.dart';
import 'package:exchange/models/active_order.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  List<ActiveOrder> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    orders = await NobitexApi.fetchActiveOrders();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 Active Orders')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text('No active orders found.'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final o = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(o.type == 'buy' ? Icons.arrow_upward : Icons.arrow_downward),
              title: Text('${o.dstCurrency.toUpperCase()} @ ${o.price}'),
              subtitle: Text('Amount: ${o.amount} | Type: ${o.type.toUpperCase()}'),
              trailing: Text(
                o.status.toUpperCase(),
                style: TextStyle(
                  color: o.status == 'waiting' ? Colors.orange : Colors.green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
