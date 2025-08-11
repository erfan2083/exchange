import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/candle_data.dart';
import '../models/crypto_price.dart';
import '../models/ohlc_data.dart';
import '../models/wallet.dart';
import '../models/active_order.dart';
import '../models/coin_stats.dart';


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
          //'Content-Type': 'application/json'
        },
      );

      final json = jsonDecode(response.body);
      if (json['status'] != 'ok') throw Exception('Unauthorized or failed');

      final wallets = (json['wallets'] as List)
          .map((item) => Wallet.fromJson(item))
          //.where((wallet) => wallet.balance == '0')
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

  static Future<CoinStats> fetchCoinStats(String symbol) async {
    final src = symbol.toLowerCase();
    final url = Uri.parse('https://apiv2.nobitex.ir/market/stats?srcCurrency=$src&dstCurrency=rls');

    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (data['status'] != 'ok') {
      throw Exception('API returned error');
    }

    final stats = data['stats']['$src-rls'];
    return CoinStats.fromJson(symbol, stats);
  }


  static Future<List<CandleData>> fetchCandleData(String symbol,
      {String resolution = 'D', int countBack = 30}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final uri = Uri.parse('https://apiv2.nobitex.ir/market/udf/history').replace(
      queryParameters: {
        'symbol': symbol,
        'resolution': resolution,
        'to': now.toString(),
        'countback': countBack.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['s'] == 'ok') {
        List<CandleData> candles = [];
        for (int i = 0; i < json['t'].length; i++) {
          candles.add(CandleData.fromJson(json, i));
        }
        return candles;
      } else {
        throw Exception('No chart data: ${json['errmsg'] ?? json['s']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  static Future<List<OhlcData>> fetchOhlcData(String symbol) async {
    // Ensure uppercase like BTCIRT
    final fullSymbol = '${symbol.toUpperCase()}IRT';

    // Unix time range (last 7 days)
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final from = now - (7 * 24 * 60 * 60);

    final url = Uri.parse(
      'https://apiv2.nobitex.ir/market/udf/history?symbol=$fullSymbol&resolution=D&from=$from&to=$now',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to load OHLC');

    final data = jsonDecode(res.body);

    if (data['s'] != 'ok') throw Exception('Invalid OHLC response');

    final List<OhlcData> chartData = [];
    for (int i = 0; i < data['t'].length; i++) {
      chartData.add(OhlcData(
        time: DateTime.fromMillisecondsSinceEpoch(data['t'][i] * 1000),
        open: (data['o'][i] as num).toDouble(),
        high: (data['h'][i] as num).toDouble(),
        low: (data['l'][i] as num).toDouble(),
        close: (data['c'][i] as num).toDouble(),
      ));
    }
    return chartData;
  }
}
