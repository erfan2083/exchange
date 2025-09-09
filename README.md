# 📱 Exchange Flutter App

A modern **crypto exchange mobile app** built with **Flutter** and the official [Nobitex API](https://apidocs.nobitex.ir/).  
This app allows users to track cryptocurrency prices in real-time, view charts, manage their wallet, and place buy/sell orders.

---

## 🚀 Features

- 🔑 **Login with API Key** (securely stored using `flutter_secure_storage`)
- 🏠 **Home Screen**
    - Wallet card with balance and USDT value
    - Highlight carousel of coins (auto-scrolling)
    - List of all available coins with live prices
- 📊 **Coin Detail Page**
    - Live coin price with high/low/change stats
    - Interactive **candlestick chart** (OHLC data from Nobitex)
    - Selectable intervals (`15m`, `1h`, `1D`)
    - Buy/Sell order form with validation
- 💼 **Assets Page**
    - Circular chart showing user’s portfolio distribution
    - List of all owned coins with current values
- 🔄 **Active Orders Page**
    - Track your open orders
- 👤 **User Session**
    - Secure API key storage
    - Logout functionality

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: Dart
- **State Management**: `setState` (simple & direct)
- **Networking**: `http`
- **Data Storage**: `flutter_secure_storage`
- **Charts**: `syncfusion_flutter_charts`
- **SVG Support**: `flutter_svg`
- **API**: [Nobitex v2 API](https://apiv2.nobitex.ir)

---

## 📦 Installation

1. Clone the repo
   ```bash
   git clone https://github.com/your-username/exchange-app.git
   cd exchange-app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

---

## 🔑 Configuration

You’ll need a **Nobitex API key** to access wallet and trade endpoints.
- On first launch, you’ll be asked to enter your API key.
- The key will be securely stored on the device using `flutter_secure_storage`.

---

## 📸 Screenshots

> Add screenshots of your app here (e.g. Home, Coin Details, Assets).

```
![Login Screen](assets/screenshots/login.png)
![Home Screen](assets/screenshots/home.png)
![Coin Detail](assets/screenshots/coin_detail.png)
```

---

## 📈 Roadmap

- [ ] Add dark/light theme toggle
- [ ] Add notifications for price alerts
- [ ] Support more exchanges (Binance, KuCoin, etc.)
- [ ] Add advanced trading options (limit/stop orders)

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you’d like to change.

---

## 📜 License

This project is licensed under the MIT License.

---

## 💡 Author

Developed by **[Your Name](https://github.com/your-username)**  
💬 Feel free to reach out if you have suggestions or ideas!
