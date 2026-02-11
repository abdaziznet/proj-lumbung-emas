# 📊 Google Sheets Setup - Panduan Lengkap

## 🎯 Struktur Database Google Sheets

Aplikasi LumbungEmas menggunakan **4 sheets** dalam 1 spreadsheet.

---

## 📋 Langkah-Langkah Setup

### Step 1: Buat Spreadsheet Baru

1. Buka [Google Sheets](https://sheets.google.com)
2. Klik **"Blank"** untuk spreadsheet baru
3. Rename spreadsheet menjadi: **"LumbungEmas Database"**

### Step 2: Buat 4 Sheets

Rename dan buat 4 sheets dengan nama **EXACT** seperti ini:

1. **Users**
2. **Transactions**
3. **Daily_Prices**
4. **Portfolio_Summary**

⚠️ **PENTING**: Nama sheet harus **PERSIS** seperti di atas (case-sensitive, dengan underscore)!

---

## 📊 Sheet 1: Users

### Nama Sheet: `Users`

### Kolom (Row 1 - Header):

| A | B | C | D | E | F |
|---|---|---|---|---|---|
| user_id | email | display_name | photo_url | created_at | last_login |

### Copy-Paste Header Ini:

```
user_id	email	display_name	photo_url	created_at	last_login
```

### Penjelasan Kolom:

| Kolom | Tipe Data | Deskripsi | Contoh |
|-------|-----------|-----------|--------|
| **user_id** | Text | ID unik user dari Firebase | `abc123xyz` |
| **email** | Text | Email user | `user@gmail.com` |
| **display_name** | Text | Nama lengkap user | `John Doe` |
| **photo_url** | Text | URL foto profil | `https://...` |
| **created_at** | Number | Timestamp registrasi (milliseconds) | `1707638400000` |
| **last_login** | Number | Timestamp login terakhir (milliseconds) | `1707638400000` |

### Contoh Data (Row 2):

```
user123	john@gmail.com	John Doe	https://example.com/photo.jpg	1707638400000	1707724800000
```

---

## 📊 Sheet 2: Transactions

### Nama Sheet: `Transactions`

### Kolom (Row 1 - Header):

| A | B | C | D | E | F | G | H | I | J | K | L |
|---|---|---|---|---|---|---|---|---|---|---|---|
| transaction_id | user_id | brand | metal_type | weight_gram | purchase_price_per_gram | total_purchase_value | purchase_date | notes | created_at | updated_at | is_deleted |

### Copy-Paste Header Ini:

```
transaction_id	user_id	brand	metal_type	weight_gram	purchase_price_per_gram	total_purchase_value	purchase_date	notes	created_at	updated_at	is_deleted
```

### Penjelasan Kolom:

| Kolom | Tipe Data | Deskripsi | Contoh |
|-------|-----------|-----------|--------|
| **transaction_id** | Text | ID unik transaksi (UUID) | `txn-abc123` |
| **user_id** | Text | ID user pemilik | `user123` |
| **brand** | Text | Brand emas/perak | `Antam`, `UBS`, `Pegadaian` |
| **metal_type** | Text | Jenis logam | `GOLD` atau `SILVER` |
| **weight_gram** | Number | Berat dalam gram | `5.5` |
| **purchase_price_per_gram** | Number | Harga beli per gram (Rupiah) | `1050000` |
| **total_purchase_value** | Number | Total nilai pembelian (Rupiah) | `5775000` |
| **purchase_date** | Number | Tanggal beli (timestamp milliseconds) | `1707638400000` |
| **notes** | Text | Catatan (opsional) | `Beli di toko X` |
| **created_at** | Number | Timestamp dibuat (milliseconds) | `1707638400000` |
| **updated_at** | Number | Timestamp update terakhir (milliseconds) | `1707638400000` |
| **is_deleted** | Text | Status hapus (soft delete) | `FALSE` atau `TRUE` |

### Contoh Data (Row 2):

```
txn-001	user123	Antam	GOLD	5	1050000	5250000	1707638400000	Pembelian pertama	1707638400000	1707638400000	FALSE
```

### ⚠️ Nilai yang Valid:

**brand**: Harus salah satu dari:
- `Antam`
- `UBS`
- `EmasKu`
- `Pegadaian`
- `Custom`

**metal_type**: Harus salah satu dari:
- `GOLD` (emas)
- `SILVER` (perak)

**is_deleted**: Harus:
- `FALSE` (aktif)
- `TRUE` (dihapus)

---

## 📊 Sheet 3: Daily_Prices

### Nama Sheet: `Daily_Prices`

### Kolom (Row 1 - Header):

| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| price_id | brand | metal_type | buy_price | sell_price | price_date | created_at | updated_by |

### Copy-Paste Header Ini:

```
price_id	brand	metal_type	buy_price	sell_price	price_date	created_at	updated_by
```

### Penjelasan Kolom:

| Kolom | Tipe Data | Deskripsi | Contoh |
|-------|-----------|-----------|--------|
| **price_id** | Text | ID unik harga (UUID) | `price-001` |
| **brand** | Text | Brand emas/perak | `Antam` |
| **metal_type** | Text | Jenis logam | `GOLD` atau `SILVER` |
| **buy_price** | Number | Harga beli per gram (Rupiah) | `1050000` |
| **sell_price** | Number | Harga jual per gram (Rupiah) | `1030000` |
| **price_date** | Number | Tanggal harga (timestamp milliseconds) | `1707638400000` |
| **created_at** | Number | Timestamp dibuat (milliseconds) | `1707638400000` |
| **updated_by** | Text | User ID yang update | `user123` |

### Contoh Data (Row 2-5):

```
price-001	Antam	GOLD	1050000	1030000	1707638400000	1707638400000	user123
price-002	Antam	SILVER	15000	14500	1707638400000	1707638400000	user123
price-003	UBS	GOLD	1055000	1035000	1707638400000	1707638400000	user123
price-004	Pegadaian	GOLD	1048000	1028000	1707638400000	1707638400000	user123
```

---

## 📊 Sheet 4: Portfolio_Summary

### Nama Sheet: `Portfolio_Summary`

### Kolom (Row 1 - Header):

| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| user_id | total_assets_value | total_invested | total_profit_loss | profit_loss_percentage | gold_value | silver_value | last_calculated |

### Copy-Paste Header Ini:

```
user_id	total_assets_value	total_invested	total_profit_loss	profit_loss_percentage	gold_value	silver_value	last_calculated
```

### Penjelasan Kolom:

| Kolom | Tipe Data | Deskripsi | Contoh |
|-------|-----------|-----------|--------|
| **user_id** | Text | ID user | `user123` |
| **total_assets_value** | Number | Total nilai aset saat ini (Rupiah) | `10500000` |
| **total_invested** | Number | Total modal yang diinvestasikan (Rupiah) | `10000000` |
| **total_profit_loss** | Number | Total profit/loss (Rupiah) | `500000` |
| **profit_loss_percentage** | Number | Persentase profit/loss | `5.0` |
| **gold_value** | Number | Total nilai emas (Rupiah) | `8000000` |
| **silver_value** | Number | Total nilai perak (Rupiah) | `2500000` |
| **last_calculated** | Number | Timestamp kalkulasi terakhir (milliseconds) | `1707638400000` |

### Contoh Data (Row 2):

```
user123	10500000	10000000	500000	5.0	8000000	2500000	1707638400000
```

---

## 🔧 Setup Permissions

### Development (Testing):

1. Klik tombol **"Share"** di kanan atas
2. Pilih **"Anyone with the link"**
3. Set permission: **"Editor"**
4. Klik **"Done"**

⚠️ **Catatan**: Ini untuk development saja. Untuk production, gunakan service account.

---

## 📝 Get Spreadsheet ID

### Cara Mendapatkan Spreadsheet ID:

1. Buka spreadsheet Anda
2. Lihat URL di browser:
   ```
   https://docs.google.com/spreadsheets/d/1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t/edit
   ```
3. Copy bagian yang saya **bold** di bawah:
   ```
   https://docs.google.com/spreadsheets/d/[COPY_INI]/edit
   ```
4. Paste ke file `.env`:
   ```env
   GOOGLE_SHEETS_SPREADSHEET_ID=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t
   ```

---

## ✅ Checklist Setup

Pastikan semua ini sudah benar:

### Sheet Names:
- [ ] Sheet 1 bernama: `Users` (exact, case-sensitive)
- [ ] Sheet 2 bernama: `Transactions` (exact, case-sensitive)
- [ ] Sheet 3 bernama: `Daily_Prices` (exact, dengan underscore)
- [ ] Sheet 4 bernama: `Portfolio_Summary` (exact, dengan underscore)

### Headers (Row 1):
- [ ] Users: 6 kolom (user_id sampai last_login)
- [ ] Transactions: 12 kolom (transaction_id sampai is_deleted)
- [ ] Daily_Prices: 8 kolom (price_id sampai updated_by)
- [ ] Portfolio_Summary: 8 kolom (user_id sampai last_calculated)

### Permissions:
- [ ] Spreadsheet bisa diakses (Anyone with the link - Editor)
- [ ] Spreadsheet ID sudah di-copy
- [ ] Spreadsheet ID sudah di-paste ke `.env`

---

## 🎨 Format Recommendations (Opsional)

### Untuk Tampilan Lebih Baik:

1. **Header Row (Row 1)**:
   - Bold
   - Background color: Light blue
   - Freeze row (View → Freeze → 1 row)

2. **Number Columns**:
   - Format sebagai Number (bukan Text)
   - Contoh: weight_gram, buy_price, sell_price

3. **Date Columns**:
   - Format sebagai Number (timestamp)
   - Atau gunakan formula untuk convert ke date

---

## 📊 Contoh Spreadsheet Lengkap

### Users Sheet:

| user_id | email | display_name | photo_url | created_at | last_login |
|---------|-------|--------------|-----------|------------|------------|
| user123 | john@gmail.com | John Doe | https://... | 1707638400000 | 1707724800000 |

### Transactions Sheet:

| transaction_id | user_id | brand | metal_type | weight_gram | purchase_price_per_gram | total_purchase_value | purchase_date | notes | created_at | updated_at | is_deleted |
|----------------|---------|-------|------------|-------------|-------------------------|---------------------|---------------|-------|------------|------------|------------|
| txn-001 | user123 | Antam | GOLD | 5 | 1050000 | 5250000 | 1707638400000 | Beli pertama | 1707638400000 | 1707638400000 | FALSE |
| txn-002 | user123 | UBS | GOLD | 2.5 | 1055000 | 2637500 | 1707724800000 | | 1707724800000 | 1707724800000 | FALSE |

### Daily_Prices Sheet:

| price_id | brand | metal_type | buy_price | sell_price | price_date | created_at | updated_by |
|----------|-------|------------|-----------|------------|------------|------------|------------|
| price-001 | Antam | GOLD | 1050000 | 1030000 | 1707638400000 | 1707638400000 | user123 |
| price-002 | Antam | SILVER | 15000 | 14500 | 1707638400000 | 1707638400000 | user123 |

### Portfolio_Summary Sheet:

| user_id | total_assets_value | total_invested | total_profit_loss | profit_loss_percentage | gold_value | silver_value | last_calculated |
|---------|-------------------|----------------|-------------------|----------------------|------------|--------------|-----------------|
| user123 | 10500000 | 10000000 | 500000 | 5.0 | 8000000 | 2500000 | 1707638400000 |

---

## 🔗 Mapping ke Source Code

### File: `lib/core/constants/app_constants.dart`

```dart
static const String usersSheetName = 'Users';
static const String transactionsSheetName = 'Transactions';
static const String dailyPricesSheetName = 'Daily_Prices';
static const String portfolioSummarySheetName = 'Portfolio_Summary';
```

### File: `lib/features/auth/data/models/user_model.dart`

```dart
factory UserModel.fromSheetRow(List<Object?> row) {
  return UserModel(
    userId: row[0]?.toString() ?? '',           // Kolom A
    email: row[1]?.toString() ?? '',            // Kolom B
    displayName: row[2]?.toString(),            // Kolom C
    photoUrl: row[3]?.toString(),               // Kolom D
    createdAt: int.parse(row[4]?.toString()),   // Kolom E
    lastLogin: int.parse(row[5]?.toString()),   // Kolom F
  );
}
```

### File: `lib/features/portfolio/data/models/metal_asset_model.dart`

```dart
factory MetalAssetModel.fromSheetRow(List<Object?> row) {
  return MetalAssetModel(
    transactionId: row[0]?.toString() ?? '',              // Kolom A
    userId: row[1]?.toString() ?? '',                     // Kolom B
    brand: row[2]?.toString() ?? '',                      // Kolom C
    metalType: row[3]?.toString() ?? 'GOLD',              // Kolom D
    weightGram: double.parse(row[4]?.toString() ?? '0'),  // Kolom E
    purchasePricePerGram: double.parse(row[5]?.toString() ?? '0'), // Kolom F
    totalPurchaseValue: double.parse(row[6]?.toString() ?? '0'),   // Kolom G
    purchaseDate: int.parse(row[7]?.toString() ?? '0'),   // Kolom H
    notes: row[8]?.toString(),                            // Kolom I
    createdAt: int.parse(row[9]?.toString() ?? '0'),      // Kolom J
    updatedAt: int.parse(row[10]?.toString() ?? '0'),     // Kolom K
    isDeleted: row[11]?.toString() == 'TRUE',             // Kolom L
  );
}
```

---

## 🛠️ Tools Helper

### Convert Timestamp ke Date (Google Sheets Formula):

Untuk melihat tanggal yang readable, tambahkan kolom helper:

```
=TEXT(A2/1000/86400 + DATE(1970,1,1), "DD/MM/YYYY HH:MM:SS")
```

### Get Current Timestamp (Google Sheets Formula):

```
=(NOW()-DATE(1970,1,1))*86400*1000
```

---

## ⚠️ Common Mistakes

### ❌ JANGAN:

1. ❌ Ubah nama sheet (harus exact: `Users`, `Transactions`, dll)
2. ❌ Ubah urutan kolom
3. ❌ Hapus kolom header
4. ❌ Gunakan spasi di nama sheet
5. ❌ Gunakan huruf kecil semua di nama sheet

### ✅ LAKUKAN:

1. ✅ Copy-paste header yang sudah disediakan
2. ✅ Gunakan nama sheet yang exact
3. ✅ Freeze header row
4. ✅ Format number columns sebagai Number
5. ✅ Test dengan data sample

---

## 🆘 Troubleshooting

### Error: "Sheet not found"

**Penyebab**: Nama sheet tidak exact  
**Solusi**: Pastikan nama sheet persis: `Users`, `Transactions`, `Daily_Prices`, `Portfolio_Summary`

### Error: "Invalid column"

**Penyebab**: Urutan kolom salah atau kolom kurang  
**Solusi**: Copy-paste header yang sudah disediakan di panduan ini

### Error: "Permission denied"

**Penyebab**: Spreadsheet tidak bisa diakses  
**Solusi**: Set permission ke "Anyone with the link - Editor"

---

## 📚 File Terkait

- **SETUP.md** - Setup instructions lengkap
- **IMPLEMENTATION_GUIDE.md** - Development guide
- **ARCHITECTURE.md** - Database schema detail

---

## ✅ Selesai!

Setelah setup selesai:

1. ✅ 4 sheets sudah dibuat dengan nama yang benar
2. ✅ Header sudah ditambahkan di row 1
3. ✅ Permission sudah di-set
4. ✅ Spreadsheet ID sudah di-copy ke `.env`

**Spreadsheet siap digunakan!** 🎉

---

**Dibuat untuk LumbungEmas App** 📊
