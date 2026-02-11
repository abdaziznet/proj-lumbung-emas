# 🎯 Panduan Cepat - Service Account JSON

## ✅ Ya, Saya Butuh File JSON Anda!

File JSON dari Google Cloud itu **sangat penting** dan lebih aman untuk production!

---

## 📋 Apa yang Harus Dilakukan dengan File JSON?

### Step 1: Simpan File JSON di Folder Aman

```bash
# Copy file JSON Anda ke folder credentials
# Rename menjadi: service-account.json
```

**Windows (File Explorer):**
1. Copy file JSON yang Anda download
2. Paste ke folder: `lumbungemas/credentials/`
3. Rename menjadi: `service-account.json`

**Windows (PowerShell):**
```powershell
# Ganti path sesuai lokasi file Anda
copy "C:\Downloads\your-file.json" credentials\service-account.json
```

---

### Step 2: Update File .env

Buka file `.env` dan tambahkan:

```env
# Service Account
GOOGLE_SERVICE_ACCOUNT_FILE=credentials/service-account.json
```

---

### Step 3: Share Spreadsheet dengan Service Account

#### 3.1. Buka File JSON

Buka file `credentials/service-account.json` dengan text editor.

#### 3.2. Cari Email Service Account

Cari baris `"client_email"`:

```json
{
  "type": "service_account",
  "project_id": "your-project",
  "client_email": "your-service-account@your-project.iam.gserviceaccount.com",
  ...
}
```

Copy email tersebut (contoh: `your-service-account@your-project.iam.gserviceaccount.com`)

#### 3.3. Share Spreadsheet

1. Buka Google Spreadsheet Anda
2. Klik tombol **"Share"** (kanan atas)
3. **Paste email service account** di kolom "Add people and groups"
4. Set permission: **"Editor"**
5. **UNCHECK** "Notify people" (karena ini bukan user biasa)
6. Klik **"Share"**

✅ **Done!** Service account sekarang bisa akses spreadsheet.

---

## 🔒 Keamanan File JSON

### ✅ Sudah Aman:

- ✅ Folder `credentials/` **SUDAH** di-gitignore
- ✅ File `service-account.json` **TIDAK AKAN** ter-commit ke Git
- ✅ File JSON **AMAN** disimpan di folder credentials

### ⚠️ Jangan:

- ❌ Jangan commit file JSON ke Git
- ❌ Jangan share file JSON di chat/email
- ❌ Jangan upload ke public storage
- ❌ Jangan screenshot file JSON

---

## 📁 Struktur Folder

```
lumbungemas/
├── .env                              ⚠️ RAHASIA
│   └── GOOGLE_SERVICE_ACCOUNT_FILE=credentials/service-account.json
│
├── credentials/                      ⚠️ RAHASIA (gitignored)
│   ├── service-account.json          ⚠️ File JSON Anda di sini!
│   ├── README.md                     ✅ Panduan
│   └── .gitkeep                      ✅ Keeps folder in Git
│
└── .gitignore                        ✅ Sudah dikonfigurasi
    └── credentials/                  ✅ Folder ini di-ignore
```

---

## 🎯 Keuntungan Service Account

### Dibanding "Anyone with the link":

| Fitur | Anyone with Link | Service Account |
|-------|-----------------|-----------------|
| **Keamanan** | ⚠️ Siapa saja bisa akses | ✅ Hanya app yang bisa akses |
| **User Login** | ⚠️ Perlu Google Sign-In | ✅ Tidak perlu login |
| **Production** | ❌ Tidak recommended | ✅ Recommended |
| **Control** | ❌ Sulit dikontrol | ✅ Mudah dikontrol |

---

## 🚀 Cara Menggunakan

### Development (Sekarang)

Untuk development, Anda bisa pilih salah satu:

**Option 1: Google Sign-In (User)**
- User perlu login dengan Google
- Spreadsheet: "Anyone with the link - Editor"

**Option 2: Service Account** ← **Recommended!**
- Tidak perlu user login
- Spreadsheet: Share dengan service account email
- Lebih aman

### Production (Nanti)

Untuk production, **WAJIB** gunakan Service Account:
- ✅ Lebih aman
- ✅ Tidak perlu user login
- ✅ Bisa dikontrol permission

---

## ✅ Checklist Setup

Pastikan semua ini sudah:

- [ ] File JSON sudah di-download dari Google Cloud
- [ ] File JSON sudah di-copy ke `credentials/service-account.json`
- [ ] File `.env` sudah di-update dengan path file
- [ ] Service account email sudah di-copy dari JSON
- [ ] Spreadsheet sudah di-share dengan service account email
- [ ] Permission spreadsheet: "Editor"

---

## 🔍 Cara Cek Apakah Sudah Benar

### Test 1: Cek File Exists

```powershell
# Harus muncul file service-account.json
dir credentials\
```

### Test 2: Cek .env

```powershell
# Harus ada baris GOOGLE_SERVICE_ACCOUNT_FILE
cat .env
```

### Test 3: Cek Gitignore

```powershell
# File JSON tidak boleh muncul di git status
git status
```

Jika `credentials/service-account.json` **TIDAK** muncul di `git status`, berarti **AMAN** ✅

---

## 📊 Contoh File JSON

File JSON Anda seharusnya berisi seperti ini:

```json
{
  "type": "service_account",
  "project_id": "lumbungemas-12345",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "lumbungemas@lumbungemas-12345.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

Yang penting:
- ✅ `"type": "service_account"` (harus ada)
- ✅ `"client_email"` (ini yang di-share ke spreadsheet)
- ✅ `"private_key"` (untuk authentication)

---

## 🆘 Troubleshooting

### File JSON tidak ada?

**Cara download:**
1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Pilih project Anda
3. Menu: IAM & Admin → Service Accounts
4. Klik service account Anda (atau buat baru)
5. Tab "Keys" → "Add Key" → "Create new key"
6. Pilih format: **JSON**
7. Download

### Spreadsheet masih error "Permission denied"?

**Solusi:**
1. Pastikan email service account sudah di-copy dengan benar
2. Share spreadsheet dengan email tersebut
3. Permission: **Editor** (bukan Viewer)
4. Uncheck "Notify people"

### File JSON corrupt?

**Solusi:**
- Download ulang dari Google Cloud Console
- Pastikan file tidak ter-edit
- Pastikan format JSON valid

---

## 📚 Dokumentasi Lengkap

Untuk penjelasan detail, baca:

1. **SERVICE_ACCOUNT_SETUP.md** ← **Panduan lengkap**
2. **credentials/README.md** ← Panduan folder credentials
3. **SECURITY_GUIDE.md** ← Security best practices

---

## 💡 Kesimpulan

File JSON Service Account yang Anda punya adalah **credentials production-grade** yang:

✅ **Lebih aman** dari "Anyone with the link"  
✅ **Tidak perlu user login** untuk akses Sheets  
✅ **Recommended** untuk production  
✅ **Sudah di-gitignore** (aman dari Git)  

**Langkah selanjutnya:**

1. ✅ Copy file JSON ke `credentials/service-account.json`
2. ✅ Update `.env` dengan path file
3. ✅ Share spreadsheet dengan service account email
4. ✅ Test authentication!

---

**Siap untuk Production!** 🚀

**File JSON Anda sangat berharga, simpan dengan aman!** 🔒
