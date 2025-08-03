class CandleData {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory CandleData.fromJson(Map<String, dynamic> json, int index) {
    return CandleData(
      timestamp: json['t'][index],
      open: json['o'][index],
      high: json['h'][index],
      low: json['l'][index],
      close: json['c'][index],
    );
  }
}
