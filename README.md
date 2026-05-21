# Artha - Personal Finance Tracker

Artha adalah aplikasi Flutter untuk mencatat keuangan harian dengan gaya UI neo-brutalism minimal.

Fokus utama:
- pencatatan pemasukan/pengeluaran yang cepat
- filter transaksi per bulan/tahun dan kategori
- budgeting bulanan per kategori
- target tabungan dan rencana investasi

## Fitur Utama

- Dashboard ringkasan saldo bulan terpilih + recent transactions
- Catatan transaksi dengan:
  - filter periode bulan/tahun
  - filter kategori
  - filter tipe (income/expense)
  - metrik Income, Expense, Net
  - pie chart pengeluaran per kategori
- Tambah transaksi (termasuk recurring rule)
- Budget per kategori per bulan + progress pemakaian
- Savings Goals: tambah/kurang dana, progress, estimasi
- Investment Plans: tambah/tarik kontribusi, progress, estimasi
- Settings:
  - dark mode
  - theme preset
  - kelola wallet
  - kelola kategori

## Tech Stack

- Flutter (Material 3)
- State Management: Riverpod
- Local Database: SQLite + Drift ORM
- Chart: fl_chart
- Utility: intl, uuid, connectivity_plus, path_provider, font_awesome_flutter

## Struktur Fitur

- `lib/features/dashboard/`
- `lib/features/transactions/`
- `lib/features/budget/`
- `lib/features/savings_goals/`
- `lib/features/investment_plans/`
- `lib/features/settings/`

## Menjalankan Project

```bash
flutter pub get
flutter run
```

## Screenshots

![Dashboard](docs/screenshots/dashboard.png)
![Transactions](docs/screenshots/transactions.png)
![Filter Sheet](docs/screenshots/filter-sheet.png)
![Add Transaction](docs/screenshots/add-transaction.png)
![Budget](docs/screenshots/budget.png)
![Savings Goals](docs/screenshots/savings-goals.png)
![Investment Plans](docs/screenshots/investment-plans.png)
![Settings](docs/screenshots/settings.png)
```
