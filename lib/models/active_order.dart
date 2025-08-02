class ActiveOrder {
  final String id;
  final String type;
  final String srcCurrency;
  final String dstCurrency;
  final String amount;
  final String price;
  final String status;

  ActiveOrder({
    required this.id,
    required this.type,
    required this.srcCurrency,
    required this.dstCurrency,
    required this.amount,
    required this.price,
    required this.status,
  });

  factory ActiveOrder.fromJson(Map<String, dynamic> json) {
    return ActiveOrder(
      id: json['id'].toString(),
      type: json['type'],
      srcCurrency: json['srcCurrency'],
      dstCurrency: json['dstCurrency'],
      amount: json['amount'],
      price: json['price'],
      status: json['status'],
    );
  }
}
