class Wallet {
  final String currency;
  final String balance;
  final String blocked;
  final String tradable;

  Wallet({
    required this.currency,
    required this.balance,
    required this.blocked,
    required this.tradable,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      currency: json['currency'],
      balance: json['balance'],
      blocked: json['blocked'],
      tradable: json['tradable'],
    );
  }
}
