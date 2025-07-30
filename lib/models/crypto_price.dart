class CryptoPrice {
  final String symbol;
  final double buyPrice;
  final double sellPrice;

  CryptoPrice({required this.symbol, required this.buyPrice, required this.sellPrice});

  factory CryptoPrice.fromJson(String symbol, Map<String, dynamic> data) {
    return CryptoPrice(
      symbol: symbol,
      buyPrice: double.parse(data['buy']),
      sellPrice: double.parse(data['sell']),
    );
  }
}
