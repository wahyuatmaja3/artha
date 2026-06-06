---

# #️⃣ Artha — Personal Finance Tracker

**Artha** adalah aplikasi manajemen keuangan harian berbasis Flutter yang menggabungkan fungsionalitas pencatatan cepat dengan estetika **Neo-Brutalism Minimal**. Didesain dengan garis tepi tebal (*high-contrast borders*), warna kontras yang berani, dan tipografi yang kuat untuk memberikan pengalaman pengguna yang unik dan responsif.

---

## 🚀 Fitur Utama

### 📊 1. Dashboard & Analisis Kontemporer

* **Ringkasan Cepat:** Pantau saldo bersih, total pemasukan, dan pengeluaran bulan berjalan langsung di halaman utama.
* **Recent Transactions:** Akses cepat ke riwayat transaksi terakhir.
* **Visualisasi fl_chart:** Grafik lingkaran (*pie chart*) interaktif untuk memetakan distribusi pengeluaran per kategori.

### 🔍 2. Manajemen Transaksi Tingkat Lanjut

* **Multi-Filter & Pencarian:** Filter data secara instan berdasarkan periode (bulan/tahun), kategori spesifik, maupun tipe transaksi (*Income/Expense*).
* **Metrik Finansial:** Kalkulasi otomatis untuk *Total Income*, *Total Expense*, dan *Net Balance*.
* **Smart Recurring:** Dukungan pencatatan otomatis untuk transaksi yang berulang secara berkala.

### 🎯 3. Alokasi Dana & Perencanaan

* **Smart Budgeting:** Tetapkan batas pengeluaran bulanan per kategori dilengkapi dengan indikator progres pemakaian visual.
* **Savings Goals:** Celengan digital untuk melacak target tabungan, kalkulasi sisa dana, dan estimasi waktu pencapaian.
* **Investment Plans:** Pantau portofolio investasi sederhana, catat kontribusi (top-up/tarik), serta estimasi pertumbuhan aset.

### ⚙️ 4. Personalisasi & Pengaturan

* **Theme Presets:** Pilihan tema warna khas neo-brutalism serta dukungan penuh untuk *Dark Mode*.
* **Wallet Manager:** Kelola banyak sumber dana (Cash, Rekening Bank, E-Wallet) dalam satu tempat.
* **Kategori Kustom:** Tambah, ubah, atau hapus kategori sesuai dengan pola pengeluaran Anda.

---

## 🛠️ Tech Stack & Arsitektur

Aplikasi ini dibangun menggunakan pola arsitektur yang modular, bersih (*clean architecture principles*), dan mengutamakan performa lokal yang solid.

| Komponen | Teknologi | Deskripsi / Kegunaan |
| --- | --- | --- |
| **Framework** | **Flutter (Material 3)** | Pembuatan UI/UX lintas platform yang responsif dengan adaptasi kustom gaya Neo-Brutalism. |
| **State Management** | **Riverpod** | Manajemen *state* yang aman (*reactive & type-safe*), mempermudah pengujian dan *caching* data. |
| **Local Database** | **Drift (SQLite)** | ORM reaktif untuk penyimpanan data lokal yang cepat, mendukung *stream* langsung ke UI. |
| **Data Visualization** | **fl_chart** | Library grafik performa tinggi untuk representasi data keuangan yang interaktif. |
| **Utilities** | `intl`, `uuid`, `path_provider`, `connectivity_plus` | Internasionalisasi mata uang/tanggal, generator ID unik, manajemen file lokal, dan deteksi status jaringan. |
| **Icons** | **Font Awesome Flutter** | Library ikon yang kaya untuk representasi visual kategori keuangan. |

---

## 📦 Struktur Proyek (Arsitektur Relevan)

```text
lib/
├── core/                  # Utilitas global, tema neo-brutalism, & konfigurasi database
│   ├── theme/             # Preset warna kontras tinggi, border style, dan font
│   └── utils/             # Formatter mata uang dan helper tanggal
├── data/                  # Sumber data (Drift DB DAOs, Tables definition)
├── providers/             # State notifier global untuk sinkronisasi data keuangan
└── features/              # Fitur modular aplikasi
    ├── dashboard/         # UI & Logic halaman ringkasan
    ├── transactions/      # Fitur catat, edit, dan filter transaksi
    ├── budgeting/         # Fitur limitasi alokasi dana per kategori
    └── savings_invest/    # Fitur target tabungan dan rencana investasi

```

---

## 🏁 Memulai (Getting Started)

Ikuti langkah-langkah berikut untuk menjalankan proyek Artha di lingkungan lokal Anda:

### Prasyarat

* Flutter SDK (Versi 3.x.x direkomendasikan)
* Dart SDK yang sesuai
* Android Studio / Xcode / VS Code

### Langkah Instalasi

1. **Clone Repositori**
```bash
git clone https://github.com/wahyuatmaja3/artha.git
cd artha

```


2. **Instal Dependensi**
```bash
flutter pub get

```


3. **Generate Kode Database (Drift)**
Karena proyek ini menggunakan Drift ORM, jalankan `build_runner` untuk menghasilkan kode generator database:
```bash
flutter pub run build_runner build --delete-conflicting-outputs

```


4. **Jalankan Aplikasi**
```bash
flutter run

```



---

## 📄 Lisensi

Proyek ini dilisensikan di bawah **MIT License** - lihat file [LICENSE](https://www.google.com/search?q=LICENSE) untuk detail lebih lanjut.

---

*Dibuat dengan 💻 dan kebebasan berekspresi Neo-Brutalism oleh [Wahyu Tri](https://www.google.com/search?q=https://github.com/wahyuatmaja3).*

--
