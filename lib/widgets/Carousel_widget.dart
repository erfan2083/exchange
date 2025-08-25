import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/crypto_price.dart';
import '../screens/coin_detail_screen.dart';


class HighlightCarousel extends StatefulWidget {
  final List<CryptoPrice> prices;

  const HighlightCarousel({Key? key, required this.prices}) : super(key: key);

  @override
  State<HighlightCarousel> createState() => _HighlightCarouselState();
}

class _HighlightCarouselState extends State<HighlightCarousel> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 0.34 باعث میشه دقیقاً 3 کارت کامل دیده بشه، بدون فضای خالی اول
    _controller = PageController(viewportFraction: 0.34);

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_controller.hasClients && widget.prices.isNotEmpty) {
        _currentPage++;

        if (_currentPage > widget.prices.length - 3) {
          // وقتی به آخر رسید → سریع ببر به اول
          _currentPage = 0;
          _controller.jumpToPage(0);
        } else {
          // در حالت عادی → انیمیشن اسکرول
          _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // ارتفاع مشخص برای جلوگیری از پرش
      child: PageView.builder(
        padEnds: false,
        controller: _controller,
        itemCount: widget.prices.length,
        onPageChanged: (index) {
          _currentPage = index; // وقتی کاربر دستی اسکرول کرد
        },
        itemBuilder: (context, index) {
          final coin = widget.prices[index];
          final symbol = coin.symbol.split('-')[0];
          return _highlightCoinTile(
            symbol,
            NumberFormat.currency(locale: 'en_US', name: '', decimalDigits: 0)
                .format(coin.buyPrice),
            Colors.primaries[index % Colors.primaries.length],
            context,
          );
        },
      ),
    );
  }
}




Widget _highlightCoinTile(
    String symbol, String price, Color color, BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CoinDetailScreen(symbol: symbol.split('-')[0].toLowerCase()),
        ),
      );
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF121330)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 12,
            child: Text(
              symbol[0],
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Text(symbol,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(price,
              style:
              const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    ),
  );
}