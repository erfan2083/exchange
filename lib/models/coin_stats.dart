class CoinStats {
  final String symbol;
  final int latest;
  final int bestBuy;
  final int bestSell;
  final int dayHigh;
  final int dayLow;
  final double dayChange;

  CoinStats({
    required this.symbol,
    required this.latest,
    required this.bestBuy,
    required this.bestSell,
    required this.dayHigh,
    required this.dayLow,
    required this.dayChange,
  });

  factory CoinStats.fromJson(String symbol, Map<String, dynamic> json) {
    return CoinStats(
      symbol: symbol.toUpperCase(),
      latest: int.parse(json['latest']),
      bestBuy: int.parse(json['bestBuy']),
      bestSell: int.parse(json['bestSell']),
      dayHigh: int.parse(json['dayHigh']),
      dayLow: int.parse(json['dayLow']),
      dayChange: double.parse(json['dayChange']),
    );
  }
}
