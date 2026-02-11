# 📋 Quick Reference - Nama Kolom Google Sheets

## Copy-Paste Headers Ini ke Spreadsheet Anda

### Sheet 1: Users
```
user_id	email	display_name	photo_url	created_at	last_login
```

### Sheet 2: Transactions
```
transaction_id	user_id	brand	metal_type	weight_gram	purchase_price_per_gram	total_purchase_value	purchase_date	notes	created_at	updated_at	is_deleted
```

### Sheet 3: Daily_Prices
```
price_id	brand	metal_type	buy_price	sell_price	price_date	created_at	updated_by
```

### Sheet 4: Portfolio_Summary
```
user_id	total_assets_value	total_invested	total_profit_loss	profit_loss_percentage	gold_value	silver_value	last_calculated
```

---

## Nama Sheet (Tab)

Buat 4 sheets dengan nama **EXACT** ini:

1. `Users`
2. `Transactions`
3. `Daily_Prices`
4. `Portfolio_Summary`

⚠️ **Case-sensitive!** Harus persis seperti di atas.

---

## Contoh Data

### Users (Row 2):
```
user123	john@gmail.com	John Doe	https://example.com/photo.jpg	1707638400000	1707724800000
```

### Transactions (Row 2):
```
txn-001	user123	Antam	GOLD	5	1050000	5250000	1707638400000	Pembelian pertama	1707638400000	1707638400000	FALSE
```

### Daily_Prices (Row 2):
```
price-001	Antam	GOLD	1050000	1030000	1707638400000	1707638400000	user123
```

### Portfolio_Summary (Row 2):
```
user123	10500000	10000000	500000	5.0	8000000	2500000	1707638400000
```

---

## Nilai yang Valid

### brand (Kolom C di Transactions & Daily_Prices):
- `Antam`
- `UBS`
- `EmasKu`
- `Pegadaian`
- `Custom`

### metal_type (Kolom D di Transactions & Daily_Prices):
- `GOLD` (emas)
- `SILVER` (perak)

### is_deleted (Kolom L di Transactions):
- `FALSE` (aktif)
- `TRUE` (dihapus)

---

## Lihat Panduan Lengkap

Buka file: **GOOGLE_SHEETS_SETUP.md**
