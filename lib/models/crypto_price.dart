class CryptoPrice {
  final String symbol;
  final double buyPrice;
  final double sellPrice;

  CryptoPrice({required this.symbol, required this.buyPrice, required this.sellPrice});

  factory CryptoPrice.fromJson(String symbol, Map<String, dynamic> data) {
    return CryptoPrice(
      symbol: symbol.toUpperCase(),
      buyPrice: double.tryParse(data['bestBuy'] ?? '0') ?? 0,
      sellPrice: double.tryParse(data['bestSell'] ?? '0') ?? 0,
    );
  }
}
