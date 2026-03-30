# LumbungEmas 🏆

**Production-Ready Precious Metal Portfolio Management Application**

A comprehensive Flutter mobile application for managing personal gold and silver savings portfolio with real-time profit/loss tracking, analytics, and Google Sheets integration.

---

## 📱 Features

### Core Features
- ✅ **Multi-Brand Portfolio Management** - Support for Antam, UBS, EmasKu, Pegadaian, and custom brands
- ✅ **Real-Time Profit/Loss Calculation** - Automatic calculation with current market prices
- ✅ **Daily Price Tracking** - Manual price update system with history
- ✅ **Google Sheets Integration** - Use Google Sheets as primary database
- ✅ **Firebase Authentication** - Secure Google Sign-In
- ✅ **Offline-First Architecture** - Works offline with background sync

### Smart Features
- 📊 **Portfolio Analytics Dashboard** - Comprehensive charts and statistics
- 🥧 **Asset Allocation Pie Chart** - Visual breakdown of gold vs silver
- 📈 **Historical Price Tracking** - Price trend visualization
- ⚖️ **Gold vs Silver Comparison** - Performance comparison charts
- 🔔 **Price Alerts** - Notifications for target prices
- 📄 **PDF Export** - Generate portfolio reports
- 🌙 **Dark Mode** - Eye-friendly dark theme
- 💰 **IDR Currency Formatting** - Indonesian Rupiah support
- 🔒 **Secure Local Caching** - SQLite for offline data
- 🔄 **Auto-Sync** - Background synchronization

---

## 🏗️ Architecture

### Clean Architecture + MVVM

```
┌─────────────────────────────────────────┐
│        Presentation Layer               │
│  (Screens, ViewModels, Widgets)         │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│          Domain Layer                    │
│  (Entities, Use Cases, Repositories)     │
└─────────────────────────────────────────┘
                  ↓ ↑
┌─────────────────────────────────────────┐
│           Data Layer                     │
│  (Models, Data Sources, Services)        │
└─────────────────────────────────────────┘
```

### Key Principles
- **SOLID Principles** - Maintainable and scalable code
- **Dependency Injection** - Using Riverpod
- **Repository Pattern** - Abstract data access
- **Offline-First** - Local cache with background sync
- **Error Handling** - Comprehensive failure handling
- **Type Safety** - Strong typing with Dart

---

## 🛠️ Technology Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.10.7+ |
| **Language** | Dart 3.10.7+ |
| **State Management** | Riverpod 2.5.0+ |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Database** | Google Sheets API (Primary), SQLite (Cache) |
| **Charts** | FL Chart, Syncfusion Charts |
| **PDF** | pdf, printing packages |
| **Design** | Material 3 |

---

## 📂 Project Structure

```
lumbungemas/
├── lib/
│   ├── core/
│   │   ├── constants/          # App constants
│   │   ├── errors/             # Error handling
│   │   ├── theme/              # App theming
│   │   └── utils/              # Utilities
│   ├── features/
│   │   ├── auth/               # Authentication
│   │   ├── portfolio/          # Portfolio management
│   │   ├── pricing/            # Price management
│   │   ├── analytics/          # Analytics & charts
│   │   └── settings/           # App settings
│   └── shared/
│       ├── data/services/      # Shared services
│       └── widgets/            # Reusable widgets
├── test/                       # Tests
├── assets/                     # Assets
├── ARCHITECTURE.md             # Architecture docs
├── IMPLEMENTATION_GUIDE.md     # Implementation guide
└── README.md                   # This file
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart SDK 3.10.7 or higher
- Android Studio / VS Code
- Google Cloud Platform account
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   cd d:/05-Labs/01-flutter/lumbungemas
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Google Sheets**
   - Create a new Google Spreadsheet
   - Copy the Spreadsheet ID
   - Update `lib/core/constants/app_constants.dart`

5. **Configure Firebase**
   - Create a Firebase project
   - Add Android app
   - Download `google-services.json`
   - Place in `android/app/`

6. **Run the app**
   ```bash
   flutter run
   ```

### Build Release

#### Build APK (release)
```bash
dart run .\tool\build.dart
```

#### Build App Bundle / AAB (release)
```bash
flutter build appbundle --release
```

For detailed setup instructions, see [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)

---

## 📊 Database Schema

### Google Sheets Structure

#### Users Sheet
| user_id | email | display_name | photo_url | created_at | last_login |

#### Transactions Sheet
| transaction_id | user_id | brand | metal_type | weight_gram | purchase_price_per_gram | total_purchase_value | purchase_date | notes | created_at | updated_at | is_deleted |

#### Daily_Prices Sheet
| price_id | brand | metal_type | buy_price | sell_price | price_date | created_at | updated_by |

#### Portfolio_Summary Sheet
| user_id | total_assets_value | total_invested | total_profit_loss | profit_loss_percentage | gold_value | silver_value | last_calculated |

---

## 🎨 Screenshots

*(Screenshots will be added after UI implementation)*

---

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run specific test
```bash
flutter test test/features/portfolio/domain/usecases/calculate_profit_loss_test.dart
```

### Generate coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📈 Roadmap

### Phase 1: MVP (Current)
- [x] Project setup
- [x] Architecture design
- [x] Core entities and models
- [ ] Google Sheets integration
- [ ] Firebase authentication
- [ ] Basic UI screens
- [ ] Profit/loss calculation

### Phase 2: Enhanced Features
- [ ] Advanced analytics
- [ ] Price alerts
- [ ] PDF export
- [ ] Dark mode
- [ ] Notifications

### Phase 3: Optimization
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Error handling improvements
- [ ] UI/UX refinements

### Phase 4: Production
- [ ] Production build
- [ ] Play Store deployment
- [ ] User documentation
- [ ] Support system

---

## 🔐 Security

- **Firebase Authentication** - Secure Google Sign-In
- **OAuth 2.0** - Google Sheets API authentication
- **Secure Storage** - Encrypted token storage
- **Input Validation** - Comprehensive form validation
- **Error Handling** - Graceful error management

---

## 🤝 Contributing

This is a personal project, but suggestions and feedback are welcome!

---

## 📄 License

This project is for personal use.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

---

## 📚 Documentation

- [Architecture Documentation](ARCHITECTURE.md)
- [Implementation Guide](IMPLEMENTATION_GUIDE.md)
- [API Documentation](docs/API.md) *(Coming soon)*

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Firebase for authentication services
- Google Sheets API for data persistence

---

## 📞 Support

For support, email your.email@example.com or open an issue in the repository.

---

**Built with ❤️ using Flutter**
