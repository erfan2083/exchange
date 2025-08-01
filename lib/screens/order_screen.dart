import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  String _orderType = 'buy';
  String _dstCurrency = 'btc';

  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final apiKey = await _storage.read(key: 'api_key');

    final response = await http.post(
      Uri.parse('https://apiv2.nobitex.ir/market/orders/add'),
      headers: {
        'Authorization': 'Token $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': _orderType,
        'srcCurrency': 'rls',
        'dstCurrency': _dstCurrency,
        'amount': _amountController.text.trim(),
        'price': _priceController.text.trim(),
      }),
    );

    setState(() => _isLoading = false);

    final json = jsonDecode(response.body);
    final msg = json['status'] == 'ok'
        ? 'Order placed successfully!'
        : 'Failed: ${json['message'] ?? 'Unknown error'}';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order Result'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _orderType,
                items: const [
                  DropdownMenuItem(value: 'buy', child: Text('Buy')),
                  DropdownMenuItem(value: 'sell', child: Text('Sell')),
                ],
                onChanged: (val) => setState(() => _orderType = val!),
                decoration: const InputDecoration(labelText: 'Order Type'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _dstCurrency,
                items: ['btc', 'eth', 'trx', 'shib']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                    .toList(),
                onChanged: (val) => setState(() => _dstCurrency = val!),
                decoration: const InputDecoration(labelText: 'Target Currency'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (e.g. 5000000)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per Unit'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Submit Order'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
