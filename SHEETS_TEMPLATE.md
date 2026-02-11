# 🎯 Template Google Sheets - Copy & Paste

## Cara Cepat Setup Spreadsheet

### 1. Buat Spreadsheet Baru
- Buka: https://sheets.google.com
- Klik "Blank"
- Rename: "LumbungEmas Database"

### 2. Buat 4 Sheets
Rename sheet default dan tambahkan 3 sheet baru dengan nama:
1. **Users**
2. **Transactions**  
3. **Daily_Prices**
4. **Portfolio_Summary**

---

## 📋 SHEET 1: Users

### Row 1 (Header) - Copy ini:
```
user_id	email	display_name	photo_url	created_at	last_login
```

### Row 2 (Contoh Data) - Opsional:
```
user123	john@gmail.com	John Doe	https://lh3.googleusercontent.com/a/default-user	1707638400000	1707724800000
```

**Jumlah Kolom**: 6 (A sampai F)

---

## 📋 SHEET 2: Transactions

### Row 1 (Header) - Copy ini:
```
transaction_id	user_id	brand	metal_type	weight_gram	purchase_price_per_gram	total_purchase_value	purchase_date	notes	created_at	updated_at	is_deleted
```

### Row 2 (Contoh Data Emas Antam) - Opsional:
```
txn-001	user123	Antam	GOLD	5	1050000	5250000	1707638400000	Pembelian emas batangan 5 gram	1707638400000	1707638400000	FALSE
```

### Row 3 (Contoh Data Emas UBS) - Opsional:
```
txn-002	user123	UBS	GOLD	2.5	1055000	2637500	1707724800000	Emas UBS 2.5 gram	1707724800000	1707724800000	FALSE
```

### Row 4 (Contoh Data Perak) - Opsional:
```
txn-003	user123	Antam	SILVER	100	15000	1500000	1707811200000	Perak batangan 100 gram	1707811200000	1707811200000	FALSE
```

**Jumlah Kolom**: 12 (A sampai L)

---

## 📋 SHEET 3: Daily_Prices

### Row 1 (Header) - Copy ini:
```
price_id	brand	metal_type	buy_price	sell_price	price_date	created_at	updated_by
```

### Row 2-9 (Contoh Data Harga) - Opsional:

**Harga Emas (GOLD):**
```
price-001	Antam	GOLD	1050000	1030000	1707638400000	1707638400000	admin
price-002	UBS	GOLD	1055000	1035000	1707638400000	1707638400000	admin
price-003	EmasKu	GOLD	1048000	1028000	1707638400000	1707638400000	admin
price-004	Pegadaian	GOLD	1052000	1032000	1707638400000	1707638400000	admin
```

**Harga Perak (SILVER):**
```
price-005	Antam	SILVER	15000	14500	1707638400000	1707638400000	admin
price-006	UBS	SILVER	15200	14700	1707638400000	1707638400000	admin
price-007	EmasKu	SILVER	14800	14300	1707638400000	1707638400000	admin
price-008	Pegadaian	SILVER	14900	14400	1707638400000	1707638400000	admin
```

**Jumlah Kolom**: 8 (A sampai H)

---

## 📋 SHEET 4: Portfolio_Summary

### Row 1 (Header) - Copy ini:
```
user_id	total_assets_value	total_invested	total_profit_loss	profit_loss_percentage	gold_value	silver_value	last_calculated
```

### Row 2 (Contoh Data) - Opsional:
```
user123	9387500	9387500	0	0	7887500	1500000	1707811200000
```

**Penjelasan Contoh:**
- Total invested: Rp 9.387.500 (5.25jt + 2.6375jt + 1.5jt)
- Gold value: Rp 7.887.500 (emas 7.5 gram)
- Silver value: Rp 1.500.000 (perak 100 gram)
- Profit/Loss: Rp 0 (belum ada perubahan harga)

**Jumlah Kolom**: 8 (A sampai H)

---

## 🎨 Format Recommendations

### Untuk Semua Sheet:

1. **Freeze Header Row**:
   - Pilih row 1
   - View → Freeze → 1 row

2. **Format Header**:
   - Bold
   - Background: Light blue (#E3F2FD)
   - Text align: Center

3. **Format Number Columns**:
   - Pilih kolom angka (weight_gram, prices, values)
   - Format → Number → Number
   - Decimal places: 2

4. **Format Timestamp Columns**:
   - Biarkan sebagai Number (untuk compatibility)
   - Atau tambah kolom helper untuk display date

### Kolom Helper untuk Tanggal (Opsional):

Tambahkan kolom di sebelah kanan timestamp untuk melihat tanggal readable.

**Formula untuk convert timestamp ke date:**
```
=TEXT(E2/1000/86400 + DATE(1970,1,1), "DD/MM/YYYY HH:MM:SS")
```

Ganti `E2` dengan cell timestamp yang ingin di-convert.

---

## 🔗 Set Permissions

### Development Mode:

1. Klik tombol **"Share"** (kanan atas)
2. Klik **"Change to anyone with the link"**
3. Set permission: **"Editor"**
4. Klik **"Done"**

⚠️ **Catatan**: Untuk production, gunakan service account (lihat SECURITY_GUIDE.md)

---

## 📝 Get Spreadsheet ID

1. Lihat URL spreadsheet:
   ```
   https://docs.google.com/spreadsheets/d/1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t/edit
   ```

2. Copy bagian ID (antara `/d/` dan `/edit`):
   ```
   1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t
   ```

3. Paste ke file `.env`:
   ```env
   GOOGLE_SHEETS_SPREADSHEET_ID=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t
   ```

---

## ✅ Verification Checklist

Setelah setup, pastikan:

### Sheet Names:
- [ ] Sheet 1: `Users` (exact)
- [ ] Sheet 2: `Transactions` (exact)
- [ ] Sheet 3: `Daily_Prices` (exact, dengan underscore)
- [ ] Sheet 4: `Portfolio_Summary` (exact, dengan underscore)

### Headers:
- [ ] Users: 6 kolom (A-F)
- [ ] Transactions: 12 kolom (A-L)
- [ ] Daily_Prices: 8 kolom (A-H)
- [ ] Portfolio_Summary: 8 kolom (A-H)

### Data:
- [ ] Header di row 1 semua sheet
- [ ] Data mulai dari row 2
- [ ] Tidak ada kolom kosong di tengah

### Access:
- [ ] Permission: "Anyone with the link - Editor"
- [ ] Spreadsheet ID sudah di-copy
- [ ] Spreadsheet ID sudah di `.env`

---

## 🚀 Quick Start

### Copy-Paste Cepat:

1. **Buat spreadsheet baru**
2. **Rename 4 sheets**: Users, Transactions, Daily_Prices, Portfolio_Summary
3. **Copy-paste header** dari template di atas ke row 1 masing-masing sheet
4. **Set permission**: Anyone with the link - Editor
5. **Copy Spreadsheet ID** ke `.env`
6. **Done!** ✅

---

## 📊 Contoh Spreadsheet Lengkap

### Visual Layout:

```
Sheet: Users
┌─────────────┬───────────────────┬──────────────┬──────────────┬───────────────┬─────────────┐
│ user_id     │ email             │ display_name │ photo_url    │ created_at    │ last_login  │
├─────────────┼───────────────────┼──────────────┼──────────────┼───────────────┼─────────────┤
│ user123     │ john@gmail.com    │ John Doe     │ https://...  │ 1707638400000 │ 1707724800000│
└─────────────┴───────────────────┴──────────────┴──────────────┴───────────────┴─────────────┘

Sheet: Transactions
┌──────────┬─────────┬───────┬────────────┬─────────────┬─────────────────────────┬──────────────────────┬───────────────┬────────┬────────────┬────────────┬────────────┐
│ trans... │ user_id │ brand │ metal_type │ weight_gram │ purchase_price_per_gram │ total_purchase_value │ purchase_date │ notes  │ created_at │ updated_at │ is_deleted │
├──────────┼─────────┼───────┼────────────┼─────────────┼─────────────────────────┼──────────────────────┼───────────────┼────────┼────────────┼────────────┼────────────┤
│ txn-001  │ user123 │ Antam │ GOLD       │ 5           │ 1050000                 │ 5250000              │ 1707638400000 │ ...    │ 1707638... │ 1707638... │ FALSE      │
└──────────┴─────────┴───────┴────────────┴─────────────┴─────────────────────────┴──────────────────────┴───────────────┴────────┴────────────┴────────────┴────────────┘

Sheet: Daily_Prices
┌───────────┬───────┬────────────┬───────────┬────────────┬───────────────┬────────────┬────────────┐
│ price_id  │ brand │ metal_type │ buy_price │ sell_price │ price_date    │ created_at │ updated_by │
├───────────┼───────┼────────────┼───────────┼────────────┼───────────────┼────────────┼────────────┤
│ price-001 │ Antam │ GOLD       │ 1050000   │ 1030000    │ 1707638400000 │ 1707638... │ admin      │
└───────────┴───────┴────────────┴───────────┴────────────┴───────────────┴────────────┴────────────┘

Sheet: Portfolio_Summary
┌─────────┬────────────────────┬────────────────┬───────────────────┬────────────────────────┬────────────┬──────────────┬─────────────────┐
│ user_id │ total_assets_value │ total_invested │ total_profit_loss │ profit_loss_percentage │ gold_value │ silver_value │ last_calculated │
├─────────┼────────────────────┼────────────────┼───────────────────┼────────────────────────┼────────────┼──────────────┼─────────────────┤
│ user123 │ 9387500            │ 9387500        │ 0                 │ 0                      │ 7887500    │ 1500000      │ 1707811200000   │
└─────────┴────────────────────┴────────────────┴───────────────────┴────────────────────────┴────────────┴──────────────┴─────────────────┘
```

---

## 🆘 Troubleshooting

### Header tidak bisa di-paste dengan tab separator?

**Solusi**: 
1. Copy text dari template
2. Paste ke cell A1
3. Spreadsheet akan otomatis split by tab

### Timestamp terlalu panjang?

**Solusi**: 
- Itu normal (milliseconds since epoch)
- Gunakan formula helper untuk convert ke date
- Atau biarkan saja (app akan handle)

### Brand atau metal_type salah?

**Solusi**: Gunakan nilai yang valid:
- **brand**: Antam, UBS, EmasKu, Pegadaian, Custom
- **metal_type**: GOLD, SILVER (huruf besar semua)

---

## 📚 Dokumentasi Terkait

- **GOOGLE_SHEETS_SETUP.md** - Panduan lengkap
- **SHEETS_COLUMNS_REFERENCE.md** - Quick reference
- **SETUP.md** - Setup instructions
- **IMPLEMENTATION_GUIDE.md** - Development guide

---

**Template Siap Digunakan!** 🎉

Copy-paste header di atas, set permission, dan mulai coding! 🚀
