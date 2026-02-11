# 🔐 Quick Security Reference

## Jawaban Singkat

**Q: Dimana saya bisa letakkan API key untuk Firebase dan Google Sheet agar tidak bisa dilihat dari GitHub?**

**A: Gunakan 3 metode ini:**

### 1️⃣ **Firebase Config** → Sudah Aman ✅
- File `google-services.json` **SUDAH** di-gitignore otomatis
- Lokasi: `android/app/google-services.json`
- **Tidak akan** ter-commit ke GitHub

### 2️⃣ **Google Sheets Spreadsheet ID** → Gunakan `.env` File
- Buat file `.env` di root project
- Tambahkan: `GOOGLE_SHEETS_SPREADSHEET_ID=your_id_here`
- File `.env` **SUDAH** di-gitignore
- **Tidak akan** ter-commit ke GitHub

### 3️⃣ **OAuth Tokens** → Secure Storage (Runtime)
- Disimpan otomatis di `FlutterSecureStorage`
- Encrypted di device
- **Tidak pernah** masuk ke Git

---

## 📋 Langkah-Langkah Setup

### Step 1: Copy File Template

```bash
cp .env.example .env
```

### Step 2: Edit File `.env`

Buka file `.env` dan isi:

```env
GOOGLE_SHEETS_SPREADSHEET_ID=1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t
```

**Cara dapat Spreadsheet ID:**
1. Buka Google Sheets Anda
2. Lihat URL-nya:
   ```
   https://docs.google.com/spreadsheets/d/[INI_SPREADSHEET_ID]/edit
   ```
3. Copy bagian `[INI_SPREADSHEET_ID]`
4. Paste ke file `.env`

### Step 3: Verify .gitignore

File `.gitignore` sudah berisi:

```gitignore
# Environment variables
.env
.env.*
!.env.example

# Firebase
**/google-services.json
**/GoogleService-Info.plist
```

✅ **Aman!** File-file ini **TIDAK AKAN** ter-commit ke GitHub.

---

## ✅ Checklist Keamanan

Pastikan hal-hal ini:

- [x] File `.env` ada di `.gitignore` ✅
- [x] File `google-services.json` ada di `.gitignore` ✅
- [x] File `.env.example` **BOLEH** di-commit (tanpa nilai asli) ✅
- [x] Tidak ada API key hardcoded di source code ✅

---

## 🚫 JANGAN Lakukan Ini

❌ **JANGAN** commit file `.env`  
❌ **JANGAN** commit `google-services.json`  
❌ **JANGAN** hardcode API key di code  
❌ **JANGAN** share `.env` via chat/email  
❌ **JANGAN** screenshot file `.env`  

---

## ✅ BOLEH Lakukan Ini

✅ **BOLEH** commit `.env.example` (template kosong)  
✅ **BOLEH** commit semua source code  
✅ **BOLEH** share `SETUP.md` dengan tim  
✅ **BOLEH** share Spreadsheet ID secara private  

---

## 📁 Struktur File

```
lumbungemas/
├── .env                        ⚠️ RAHASIA - Jangan commit!
├── .env.example                ✅ AMAN - Boleh commit
├── .gitignore                  ✅ AMAN - Sudah dikonfigurasi
├── android/
│   └── app/
│       └── google-services.json  ⚠️ RAHASIA - Jangan commit!
└── lib/
    └── core/
        └── config/
            └── app_config.dart   ✅ AMAN - Load dari .env
```

---

## 🔍 Cara Cek Apakah Aman

### Test 1: Cek .gitignore

```bash
cat .gitignore | grep ".env"
```

Harus muncul: `.env`

### Test 2: Cek Git Status

```bash
git status
```

File `.env` dan `google-services.json` **TIDAK BOLEH** muncul di list.

### Test 3: Coba Add File

```bash
git add .env
```

Harusnya **TIDAK** bisa ter-add (karena di-gitignore).

---

## 🆘 Kalau Sudah Terlanjur Commit

Jika **sudah terlanjur** commit file rahasia:

### 1. Hapus dari Git History

```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all
```

### 2. Force Push (HATI-HATI!)

```bash
git push origin --force --all
```

### 3. Ganti Semua Credentials

- Buat Spreadsheet baru
- Rotate Firebase API keys
- Update `.env` dengan credentials baru

---

## 📚 Dokumentasi Lengkap

Untuk penjelasan detail, baca:

1. **SECURITY_GUIDE.md** - Panduan keamanan lengkap
2. **SETUP.md** - Instruksi setup step-by-step
3. **IMPLEMENTATION_GUIDE.md** - Guide implementasi

---

## 💡 Tips Tambahan

### Untuk Development

```env
# .env (development)
GOOGLE_SHEETS_SPREADSHEET_ID=dev_spreadsheet_id
ENVIRONMENT=development
```

### Untuk Production

```env
# .env (production)
GOOGLE_SHEETS_SPREADSHEET_ID=prod_spreadsheet_id
ENVIRONMENT=production
```

### Gunakan Spreadsheet Berbeda

- **Development**: Spreadsheet untuk testing
- **Production**: Spreadsheet untuk data real

---

## ✨ Kesimpulan

### API Keys Disimpan Di:

| Item | Lokasi | Aman? |
|------|--------|-------|
| **Spreadsheet ID** | `.env` file | ✅ Ya (gitignored) |
| **Firebase Config** | `google-services.json` | ✅ Ya (gitignored) |
| **OAuth Tokens** | Secure Storage (runtime) | ✅ Ya (encrypted) |
| **Source Code** | Git repository | ✅ Ya (no secrets) |

### Semua Sudah Dikonfigurasi! 🎉

- ✅ `.gitignore` sudah benar
- ✅ `.env.example` sudah ada
- ✅ `AppConfig` sudah siap
- ✅ `SecureStorageService` sudah siap
- ✅ Dokumentasi lengkap tersedia

**Tinggal:**
1. Copy `.env.example` → `.env`
2. Isi Spreadsheet ID
3. Download `google-services.json` dari Firebase
4. Mulai coding! 🚀

---

**Aman dan Siap Digunakan!** 🔒
