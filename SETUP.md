# Setup Instructions

## 🚀 Quick Start Guide

Follow these steps to set up the LumbungEmas project on your local machine.

---

## 1. Prerequisites

Ensure you have the following installed:

- ✅ Flutter SDK 3.10.7 or higher
- ✅ Dart SDK 3.10.7 or higher
- ✅ Android Studio or VS Code
- ✅ Git

---

## 2. Clone Repository

```bash
git clone https://github.com/yourusername/lumbungemas.git
cd lumbungemas
```

---

## 3. Configure Environment Variables

### Step 1: Create .env file

```bash
# Copy the example file
cp .env.example .env
```

### Step 2: Edit .env file

Open `.env` and configure your settings:

```env
# Required: Your Google Sheets Spreadsheet ID
GOOGLE_SHEETS_SPREADSHEET_ID=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t

# Optional: Environment
ENVIRONMENT=development
```

### How to get Spreadsheet ID:

1. Open your Google Spreadsheet
2. Look at the URL:
   ```
   https://docs.google.com/spreadsheets/d/[SPREADSHEET_ID]/edit
   ```
3. Copy the `SPREADSHEET_ID` part
4. Paste it in your `.env` file

---

## 4. Firebase Configuration

### Android Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (or create new)
3. Go to Project Settings → Your apps → Android app
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

### iOS Setup (Optional)

1. In Firebase Console, go to iOS app
2. Download `GoogleService-Info.plist`
3. Place it in: `ios/Runner/GoogleService-Info.plist`

### Enable Google Sign-In

1. In Firebase Console → Authentication → Sign-in method
2. Enable "Google" provider
3. Add your SHA-1 fingerprint:

```bash
# Get debug SHA-1
cd android
./gradlew signingReport
```

---

## 5. Google Sheets Setup

### Create Spreadsheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet named "LumbungEmas Database"
3. Create 4 sheets with these exact names:
   - `Users`
   - `Transactions`
   - `Daily_Prices`
   - `Portfolio_Summary`

### Add Headers

#### Users Sheet (Row 1):
```
user_id | email | display_name | photo_url | created_at | last_login
```

#### Transactions Sheet (Row 1):
```
transaction_id | user_id | brand | metal_type | weight_gram | purchase_price_per_gram | total_purchase_value | purchase_date | notes | created_at | updated_at | is_deleted
```

#### Daily_Prices Sheet (Row 1):
```
price_id | brand | metal_type | buy_price | sell_price | price_date | created_at | updated_by
```

#### Portfolio_Summary Sheet (Row 1):
```
user_id | total_assets_value | total_invested | total_profit_loss | profit_loss_percentage | gold_value | silver_value | last_calculated
```

### Set Permissions

1. Click "Share" button
2. For development: "Anyone with the link can edit"
3. For production: Use service account (see SECURITY_GUIDE.md)

---

## 6. Install Dependencies

```bash
flutter pub get
```

---

## 7. Run the App

```bash
# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

---

## 8. Verify Setup

The app should:
- ✅ Load without errors
- ✅ Show splash screen
- ✅ Allow Google Sign-In
- ✅ Connect to Google Sheets

---

## 🔧 Troubleshooting

### Error: "GOOGLE_SHEETS_SPREADSHEET_ID not found"

**Solution**: Make sure you created `.env` file and added your spreadsheet ID.

### Error: "google-services.json not found"

**Solution**: Download from Firebase Console and place in `android/app/`

### Error: "Failed to connect to Google Sheets"

**Solution**: 
1. Check spreadsheet permissions
2. Verify spreadsheet ID in `.env`
3. Ensure Google Sign-In is enabled in Firebase

### Build errors

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
lumbungemas/
├── .env                    # ⚠️ Your config (DO NOT COMMIT)
├── .env.example            # ✅ Template (committed)
├── android/
│   └── app/
│       └── google-services.json  # ⚠️ Firebase config (DO NOT COMMIT)
├── lib/
│   ├── main.dart
│   ├── core/
│   │   └── config/
│   │       └── app_config.dart   # Loads .env
│   └── ...
└── ...
```

---

## ⚠️ Important Security Notes

### DO NOT COMMIT:
- ❌ `.env` file
- ❌ `google-services.json`
- ❌ `GoogleService-Info.plist`
- ❌ Any file with API keys or secrets

### SAFE TO COMMIT:
- ✅ `.env.example`
- ✅ All source code
- ✅ Documentation

---

## 🤝 Team Collaboration

### When joining the team:

1. Ask team lead for:
   - Firebase project access
   - Google Sheets access
   - Spreadsheet ID

2. Follow this setup guide

3. Never share your `.env` file in:
   - Chat messages
   - Email
   - Screenshots
   - Screen sharing

### When updating configuration:

1. Update `.env.example` (without real values)
2. Notify team members
3. Update `SETUP.md` if needed

---

## 📚 Additional Resources

- [SECURITY_GUIDE.md](SECURITY_GUIDE.md) - Security best practices
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) - Development guide
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)

---

## ✅ Setup Checklist

- [ ] Flutter SDK installed
- [ ] Repository cloned
- [ ] `.env` file created and configured
- [ ] `google-services.json` added
- [ ] Google Sheets created with 4 sheets
- [ ] Headers added to all sheets
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs successfully
- [ ] Google Sign-In works
- [ ] Can connect to Google Sheets

---

## 🆘 Need Help?

1. Check [SECURITY_GUIDE.md](SECURITY_GUIDE.md)
2. Check [Troubleshooting](#troubleshooting) section
3. Review error messages carefully
4. Contact team lead

---

**Happy Coding! 🚀**
