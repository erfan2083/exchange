import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'سبد دارایی شما هنوز خالی است',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
