# #️⃣ Artha — Personal Finance Tracker

**Artha** adalah aplikasi manajemen keuangan harian berbasis Flutter yang menggabungkan fungsionalitas pencatatan instan dengan estetika **Neo-Brutalism Minimal**. Didesain dengan garis tepi tebal (*high-contrast borders*), warna kontras yang berani, dan tipografi yang kuat, Artha menawarkan pengalaman pengelolaan finansial yang unik, ekspresif, dan tetap responsif.

---

## 🚀 Fitur Utama

### 📊 1. Dashboard & Analisis Kontemporer
* **Ringkasan Finansial:** Pantau saldo bersih, total pemasukan, dan pengeluaran bulan berjalan secara real-time di halaman utama.
* **Riwayat Transaksi:** Akses cepat ke daftar transaksi terbaru untuk monitoring yang lebih mudah.
* **Visualisasi Interaktif:** Grafik lingkaran (*pie chart*) dinamis berbasis `fl_chart` untuk memetakan distribusi pengeluaran per kategori.

### 🔍 2. Manajemen Transaksi Tingkat Lanjut
* **Pencarian & Multi-Filter:** Filter data secara instan berdasarkan periode (bulan/tahun), kategori spesifik, maupun tipe transaksi (*Income/Expense*).
* **Metrik Otomatis:** Kalkulasi akurat untuk akun *Total Income*, *Total Expense*, dan *Net Balance*.
* **Smart Recurring:** Dukungan pencatatan otomatis untuk transaksi rutin yang berulang secara berkala.

### 🎯 3. Alokasi Dana & Perencanaan
* **Smart Budgeting:** Tetapkan batasan pengeluaran bulanan per kategori yang dilengkapi dengan indikator visual progres pemakaian.
* **Savings Goals:** Celengan digital untuk melacak target tabungan, lengkap dengan kalkulasi sisa dana dan estimasi waktu pencapaian.
* **Investment Plans:** Pantau portofolio investasi sederhana, catat kontribusi (top-up/penarikan), serta estimasi pertumbuhan aset.

### ⚙️ 4. Personalisasi & Pengaturan
* **Theme Presets:** Pilihan tema warna khas Neo-Brutalism dengan dukungan penuh untuk mode gelap (*Dark Mode*).
* **Wallet Manager:** Kelola banyak sumber dana (Tunai, Rekening Bank, E-Wallet) dalam satu dasbor terintegrasi.
* **Kategori Kustom:** Kebebasan untuk menambah, mengubah, atau menghapus kategori sesuai dengan pola pengeluaran Anda.

---

## 🛠️ Tech Stack & Arsitektur

Aplikasi ini dibangun menggunakan arsitektur modular yang bersih (*Clean Architecture principles*) untuk memastikan kode mudah dirawat, diuji, dan memiliki performa lokal yang solid.

| Komponen | Teknologi | Deskripsi / Kegunaan |
| --- | --- | --- |
| **Framework** | **Flutter (Material 3)** | Pengembangan UI/UX lintas platform dengan adaptasi kustom gaya Neo-Brutalism. |
| **State Management** | **Riverpod** | Manajemen *state* yang aman (*reactive & type-safe*), mempermudah pengujian dan *caching* data. |
| **Local Database** | **Drift (SQLite)** | ORM reaktif untuk penyimpanan data lokal yang cepat dan mendukung *stream* langsung ke UI. |
| **Data Visualization** | **fl_chart** | Library grafik performa tinggi untuk representasi visual data keuangan. |
| **Utilities** | `intl`, `uuid`, `path_provider`, `connectivity_plus` | Internasionalisasi (mata uang/tanggal), generator ID unik, manajemen file lokal, dan deteksi status jaringan. |
| **Icons** | **Font Awesome Flutter** | Library ikon yang kaya untuk representasi visual kategori keuangan. |

---

## 📦 Struktur Proyek

```text
lib/
├── core/                  # Utilitas global, tema neo-brutalism, & konfigurasi database
│   ├── theme/             # Preset warna kontras tinggi, border style, dan tipografi
│   └── utils/             # Formatter mata uang dan helper tanggal
├── data/                  # Sumber data (Drift DB DAOs & Table Definitions)
├── providers/             # State notifier global untuk sinkronisasi data keuangan
└── features/              # Fitur modular aplikasi berbasis komponen
    ├── dashboard/         # UI & Logika halaman ringkasan
    ├── transactions/      # Fitur pencatatan, penyuntingan, dan filtrasi transaksi
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
   git clone [https://github.com/wahyuatmaja3/artha.git](https://github.com/wahyuatmaja3/artha.git)
   cd artha

```

2. **Instal Dependensi**

```bash
   flutter pub get

```

3. **Generate Kode Database (Drift)**
Proyek ini menggunakan Drift ORM, jalankan `build_runner` untuk menghasilkan kode generator database:

```bash
   dart run build_runner build --delete-conflicting-outputs

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

```

---
