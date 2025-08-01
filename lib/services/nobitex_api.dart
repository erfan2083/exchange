import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_price.dart';

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
}
