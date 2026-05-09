# PRODUCT REQUIREMENT DOCUMENT

## Technical Architecture — Flutter Budgeting App

## 1. Architecture Overview

Architecture Type:
Offline-First Hybrid Architecture

Layers:

* Presentation Layer (Flutter UI)
* State Management Layer
* Local Data Layer (SQLite / Drift)
* Local Data Layer (SQLite / Drift)

Goal:

* App usable tanpa internet
* Semua data tersimpan lokal di perangkat

---

## 2. Technology Stack

Frontend:

* Flutter
* State Management: Riverpod / Bloc

Local Database:

* SQLite via Drift ORM

Storage Engine:

* SQLite via Drift ORM

Charts:

* fl_chart package

---

## 3. Database Entities

Users

* id
* email
* created_at

Wallets

* id
* user_id
* name
* balance
* created_at

Categories

* id
* user_id
* name
* type
* icon

Transactions

* id
* user_id
* wallet_id
* category_id
* amount
* note
* transaction_date
* created_at
* updated_at
* sync_status

Budgets

* id
* user_id
* category_id
* month
* limit_amount

---

## 4. Core Features Logic

Transaction Creation:

* Insert into local DB first
* Update wallet balance locally
* Mark sync_status = pending
* Perubahan langsung tersimpan ke SQLite lokal

Dashboard Calculation:

* Total balance = sum(wallet.balance)
* Monthly expense = sum(expense transaction)
* Budget remaining = limit − used

Budget Tracking:

* Query transactions by category + month
* Calculate usage percentage
* Trigger warning state if exceeded

---

## 5. Local Persistence Mechanism

Persistence Triggers:

* App launch (load local data)
* After transaction creation
* After wallet/category/budget updates

Persistence Strategy:

* Semua perubahan ditulis langsung ke SQLite
* Query dashboard dan laporan membaca dari SQLite
* Tidak ada push/pull ke server

---

## 6. Performance Requirements

* Transaction insert < 100ms
* Dashboard load < 500ms
* Query data lokal tetap responsif untuk 100+ records

---

## 7. Security Requirements

* Data tersimpan lokal di perangkat pengguna
* Tidak ada autentikasi server pada versi SQLite-only

---

## 8. Future Scalability

Possible Features:

* Recurring transactions
* Financial reports PDF export
* Spending prediction
* AI finance insights
* Bank integration API
