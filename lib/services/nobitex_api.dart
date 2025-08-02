import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/crypto_price.dart';
import '../models/wallet.dart';
import '../models/active_order.dart';

class NobitexApi {
  static Future<List<CryptoPrice>> fetchPrices() async {
    try {
      final url = Uri.parse('https://apiv2.nobitex.ir/market/stats?dstCurrency=rls');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch market data');
      }

      final json = jsonDecode(response.body);

      if (json['status'] != 'ok') {
        throw Exception('API returned failure');
      }

      final stats = json['stats'] as Map<String, dynamic>;

      return stats.entries.map((e) {
        final symbol = e.key; // e.g. btc-rls
        final data = e.value as Map<String, dynamic>;
        return CryptoPrice.fromJson(symbol, data);
      }).toList();
    } catch (e) {
      print('API error: $e');
      return [];
    }
  }

  static Future<List<Wallet>> fetchWallets() async {
    try {
      final storage = FlutterSecureStorage();
      final apiKey = await storage.read(key: 'api_key');
      if (apiKey == null || apiKey.isEmpty) throw Exception('API Key missing');

      final url = Uri.parse('https://apiv2.nobitex.ir/users/wallets/list');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'application/json'
        },
      );

      final json = jsonDecode(response.body);
      if (json['status'] != 'ok') throw Exception('Unauthorized or failed');

      final wallets = (json['wallets'] as List)
          .map((item) => Wallet.fromJson(item))
          .where((wallet) => wallet.balance != '0')
          .toList();

      return wallets;
    } catch (e) {
      print('Wallet fetch error: $e');
      return [];
    }
  }

  static Future<List<ActiveOrder>> fetchActiveOrders() async {
    try {
      final storage = FlutterSecureStorage();
      final apiKey = await storage.read(key: 'api_key');
      if (apiKey == null || apiKey.isEmpty) throw Exception('Missing API Key');

      final url = Uri.parse('https://apiv2.nobitex.ir/market/orders/list/active/');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'application/json',
        },
      );

      final json = jsonDecode(response.body);
      if (json['status'] != 'ok') throw Exception(json['message'] ?? 'Unknown error');

      final orders = (json['orders'] as List)
          .map((order) => ActiveOrder.fromJson(order))
          .toList();

      return orders;
    } catch (e) {
      print('Active order error: $e');
      return [];
    }
  }
}
