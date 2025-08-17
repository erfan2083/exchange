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

      // 🟢 فیلتر کردن کوین‌هایی که قیمتشون صفر یا null هست
      return stats.entries.map((e) {
        final symbol = e.key; // e.g. btc-rls
        final data = e.value as Map<String, dynamic>;
        return CryptoPrice.fromJson(symbol, data);
      }).where((coin) => coin.buyPrice != 0 && coin.sellPrice != 0).toList();
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


  static Future<List<OhlcData>> fetchOhlcData(
      String symbol, {
        String resolution = "D", // Default: daily candles
        int? fromTimestamp,      // Optional custom start time (Unix)
        int? toTimestamp,        // Optional custom end time (Unix)
      }) async {

    // Ensure uppercase symbol, but don't force IRT if symbol already has a suffix
    final fullSymbol = symbol.contains("IRT") || symbol.contains("USDT")
        ? symbol.toUpperCase()
        : '${symbol.toUpperCase()}IRT';

    // Default time range: last 7 days
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final to = toTimestamp ?? now;
    final from = fromTimestamp ?? (to - (7 * 24 * 60 * 60));

    final url = Uri.parse(
      'https://apiv2.nobitex.ir/market/udf/history'
          '?symbol=$fullSymbol'
          '&resolution=$resolution'
          '&from=$from'
          '&to=$to',
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


  // === GET BALANCE ===
  static Future<Map<String, double>> getBalances() async {
    final storage = FlutterSecureStorage();
    final apiKey = await storage.read(key: 'api_key');
    if (apiKey == null || apiKey.isEmpty) throw Exception('Missing API Key');

    final response = await http.post(
      Uri.parse("https://apiv2.nobitex.ir/users/wallets/list"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $apiKey", // Replace with your token
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch balances");
    }

    final data = jsonDecode(response.body);
    if (data["status"] != "ok") {
      throw Exception(data["message"] ?? "Failed to fetch balances");
    }

    Map<String, double> balances = {};
    for (var wallet in data["wallets"]) {
      balances[wallet["currency"].toLowerCase()] =
          double.parse(wallet["balance"]);
    }
    return balances;
  }

// === PLACE ORDER ===
  static Future<String> placeOrder({
    required String type, // buy or sell
    required String symbol, // BTCIRT
    required double amount,
    required double price,
    String execution = "limit",
  }) async {
    final srcCurrency = symbol.substring(0, 3).toLowerCase();
    final dstCurrency = symbol.substring(3).toLowerCase();

    final response = await http.post(
      Uri.parse("https://apiv2.nobitex.ir/market/orders/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token YOUR_API_KEY",
      },
      body: jsonEncode({
        "type": type,
        "execution": execution,
        "srcCurrency": srcCurrency,
        "dstCurrency": dstCurrency,
        "amount": amount.toString(),
        "price": price.toString(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to place order");
    }

    final data = jsonDecode(response.body);
    if (data["status"] == "ok") {
      return "Order placed successfully!";
    } else {
      return "Error: ${data['message'] ?? 'Unknown error'}";
    }
  }

}
