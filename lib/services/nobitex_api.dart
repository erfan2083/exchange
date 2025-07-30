import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_price.dart';

class NobitexApi {
  static Future<List<CryptoPrice>> fetchPrices() async {
    final url = Uri.parse('https://apiv2.nobitex.ir/market/stats');
    final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'srcCurrency': 'usdt', 'dstCurrency': 'btc,eth'}
    );
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final stats = json['stats'] as Map<String, dynamic>;
      return stats.entries.map((e) => CryptoPrice.fromJson(e.key, e.value)).toList();
    } else {
      throw Exception('Failed to load prices');
    }
  }
}
