# PRD — Future Financial Planning Features

## Overview

Dokumen ini berisi detail fitur tambahan untuk aplikasi pencatatan keuangan yang berfokus pada perencanaan finansial, pengelolaan tujuan keuangan, pengeluaran masa depan, investasi, dan utang.

Fitur ini dirancang agar saling terhubung dengan sistem transaksi, akun aset, dan akun utang yang sudah ada pada aplikasi.

---

# Feature List

1. Recurring Transaction
2. Savings Goal
3. Event Planning
4. Investment Plan
5. Debt Planner
6. Financial Plan

---

# 1. Recurring Transaction

## Description

Fitur untuk membuat transaksi otomatis yang terjadi secara berulang berdasarkan periode tertentu.

Contoh penggunaan:

* Gaji bulanan
* Tagihan listrik
* Langganan aplikasi
* Cicilan kendaraan
* Bayar kos

---

## Goals

* Mengurangi input transaksi manual
* Membantu user tidak lupa transaksi rutin
* Membuat pencatatan lebih konsisten

---

## User Stories

### Create Recurring

Sebagai user, saya ingin membuat transaksi berulang agar transaksi rutin tidak perlu dicatat manual.

### Auto Generate

Sebagai user, saya ingin transaksi otomatis dibuat sesuai jadwal yang ditentukan.

### Reminder

Sebagai user, saya ingin mendapatkan pengingat sebelum transaksi jatuh tempo.

---

## Main Features

### Create Recurring Rule

User dapat menentukan:

* Nama transaksi
* Nominal
* Jenis transaksi

  * Income
  * Expense
  * Transfer
* Kategori
* Akun terkait
* Frekuensi:

  * Harian
  * Mingguan
  * Bulanan
  * Tahunan
* Tanggal mulai
* Tanggal selesai (optional)
* Catatan
* Reminder ON/OFF
* Auto-create transaction ON/OFF

---

### Recurring Execution

Sistem akan:

* Membuat transaksi otomatis saat jadwal tiba
* Menandai transaksi sebagai generated transaction
* Menghindari duplicate transaction

---

### Recurring Management

User dapat:

* Pause recurring
* Resume recurring
* Edit recurring
* Delete recurring

---

### Recurring History

User dapat melihat:

* Riwayat transaksi yang dibuat otomatis
* Jadwal transaksi berikutnya
* Status recurring aktif/nonaktif

---

# 2. Savings Goal

## Description

Fitur untuk membuat target tabungan berdasarkan tujuan tertentu.

Contoh:

* Dana darurat
* Liburan
* Beli laptop
* DP rumah
* Kendaraan

---

## Goals

* Membantu user menabung secara terarah
* Memotivasi user mencapai target finansial
* Membantu perencanaan dana masa depan

---

## User Stories

### Create Goal

Sebagai user, saya ingin membuat target tabungan agar memiliki tujuan finansial yang jelas.

### Track Progress

Sebagai user, saya ingin melihat perkembangan tabungan saya.

### Add Contribution

Sebagai user, saya ingin menambahkan dana ke target tabungan saya.

---

## Main Features

### Create Savings Goal

Field:

* Nama target
* Target nominal
* Target date
* Priority
* Deskripsi
* Akun penyimpanan terkait
* Icon/cover

---

### Progress Tracking

Sistem menampilkan:

* Total terkumpul
* Sisa target
* Persentase progress
* Estimasi tercapai
* Kebutuhan tabungan per bulan

---

### Contribution

User dapat:

* Menambahkan dana manual
* Mengambil dana dari target
* Memindahkan dana dari transaksi tertentu

---

### Savings Status

Status:

* Ongoing
* Completed
* Failed
* Paused

---

## Special Savings Type

### Emergency Fund

Template khusus:

* Target berdasarkan pengeluaran bulanan
* Rekomendasi:

  * 3 bulan pengeluaran
  * 6 bulan pengeluaran
  * 12 bulan pengeluaran

---

# 3. Event Planning

## Description

Fitur untuk merencanakan pengeluaran berdasarkan event tertentu.

Contoh:

* Pernikahan
* Liburan
* Lebaran
* Ulang tahun
* Konser
* Wisuda

---

## Goals

* Membantu user mengontrol pengeluaran event
* Menghindari overbudget
* Membantu persiapan dana event

---

## User Stories

### Create Event

Sebagai user, saya ingin membuat event agar pengeluaran event dapat dipisahkan dari pengeluaran biasa.

### Monitor Spending

Sebagai user, saya ingin memonitor total pengeluaran event.

---

## Main Features

### Create Event Plan

Field:

* Nama event
* Tanggal event
* Total budget
* Deskripsi
* Kategori pengeluaran terkait

---

### Event Expense Tracking

Sistem dapat:

* Menghubungkan transaksi ke event tertentu
* Menghitung total pengeluaran event
* Menghitung sisa budget

---

### Event Analytics

Menampilkan:

* Budget vs actual spending
* Breakdown pengeluaran
* Persentase penggunaan budget

---

### Event Reminder

Reminder:

* Event mendekat
* Budget hampir habis
* Pengeluaran melebihi budget

---

# 4. Investment Plan

## Description

Fitur untuk membuat rencana investasi berkala yang terhubung dengan akun aset user.

Contoh:

* DCA crypto
* Investasi saham bulanan
* Reksadana mingguan
* Emas bulanan

---

## Goals

* Membantu user konsisten investasi
* Membantu user mengatur target investasi
* Memberikan gambaran progress investasi

---

## User Stories

### Create Investment Plan

Sebagai user, saya ingin membuat rencana investasi agar investasi saya lebih teratur.

### Track Investment Progress

Sebagai user, saya ingin melihat perkembangan investasi saya.

---

## Main Features

### Create Investment Plan

Field:

* Nama plan
* Jenis investasi
* Akun aset terkait
* Target nominal
* Alokasi dana berkala
* Frekuensi investasi
* Tanggal mulai
* Catatan

---

### Investment Tracking

Menampilkan:

* Total investasi
* Progress target
* Riwayat kontribusi
* Estimasi target tercapai

---

### Auto Allocation (Optional)

User dapat:

* Menghubungkan recurring transaction
* Mengalokasikan sebagian income ke investasi

---

### Investment Status

Status:

* Active
* Completed
* Paused
* Cancelled

---

# 5. Debt Planner

## Description

Fitur untuk membantu user mengatur strategi pelunasan utang yang terhubung dengan akun utang.

Contoh:

* Cicilan kendaraan
* Pinjaman online
* Kartu kredit
* Utang pribadi

---

## Goals

* Membantu user mengontrol utang
* Memberikan estimasi pelunasan
* Membantu user mengurangi bunga utang

---

## User Stories

### Create Debt Plan

Sebagai user, saya ingin membuat strategi pelunasan utang agar utang saya lebih teratur.

### Track Debt Progress

Sebagai user, saya ingin melihat progres pelunasan utang.

---

## Main Features

### Create Debt Planner

Field:

* Nama utang
* Akun utang terkait
* Total utang
* Suku bunga
* Minimum pembayaran
* Pembayaran tambahan
* Jatuh tempo

---

### Debt Tracking

Menampilkan:

* Sisa utang
* Total bunga
* Progress pelunasan
* Estimasi lunas

---

### Repayment Strategy

Support:

* Snowball Method
* Avalanche Method
* Custom payment

---

### Payment Reminder

Reminder:

* Jatuh tempo
* Pembayaran tertunda
* Tagihan mendatang

---

### Debt Status

Status:

* Active
* Paid Off
* Overdue
* Paused

---

# 6. Financial Plan

## Description

Fitur roadmap finansial untuk membantu user membuat tujuan finansial jangka pendek hingga jangka panjang.

Contoh:

* Menikah
* Beli rumah
* Dana pensiun
* Financial freedom
* Pendidikan anak

---

## Goals

* Membantu user memiliki roadmap finansial
* Membantu prioritas tujuan keuangan
* Membantu perhitungan kebutuhan finansial masa depan

---

## User Stories

### Create Financial Goal

Sebagai user, saya ingin membuat tujuan finansial agar memiliki arah pengelolaan uang yang jelas.

### Track Goal Achievement

Sebagai user, saya ingin melihat progress pencapaian tujuan finansial saya.

---

## Main Features

### Create Financial Goal

Field:

* Nama tujuan
* Target nominal
* Target date
* Priority
* Kategori tujuan
* Catatan

---

### Financial Roadmap

Sistem menampilkan:

* Short term goals
* Mid term goals
* Long term goals

---

### Goal Analysis

Sistem menghitung:

* Kebutuhan tabungan bulanan
* Estimasi ketercapaian
* Selisih target dengan kemampuan finansial

---

### Goal Recommendation

Sistem dapat memberikan:

* Prioritas tujuan
* Rekomendasi alokasi dana
* Peringatan jika target sulit tercapai

---

### Financial Goal Status

Status:

* Planned
* Ongoing
* Achieved
* Delayed
* Cancelled

---

# Feature Integration

## Savings ↔ Financial Plan

Savings goal dapat dihubungkan ke financial goal tertentu.

Contoh:

* Financial Goal: Beli Rumah
* Savings Goal: DP Rumah

---

## Debt Planner ↔ Recurring

Pembayaran utang dapat dibuat recurring otomatis.

---

## Investment Plan ↔ Asset Account

Investment plan terhubung langsung ke akun aset user.

---

## Event ↔ Savings

Event dapat memiliki target tabungan sendiri.

Contoh:

* Event: Liburan Jepang
* Savings: Dana Liburan Jepang

---

# Future Enhancements

* Auto budgeting
* Smart recommendation
* AI financial assistant
* Financial scoring
* Predictive cashflow
* Investment simulation
* Retirement planning
* Shared financial goals
* Family financial planning
