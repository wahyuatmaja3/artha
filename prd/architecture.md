# PRODUCT REQUIREMENT DOCUMENT

## Technical Architecture — Flutter Budgeting App

## 1. Architecture Overview

Architecture Type:
Offline-First Hybrid Architecture

Layers:

* Presentation Layer (Flutter UI)
* State Management Layer
* Local Data Layer (SQLite / Drift)
* Remote Data Layer (Supabase)
* Sync Engine

Goal:

* App usable without internet
* Automatic cloud synchronization
* Conflict resolution support

---

## 2. Technology Stack

Frontend:

* Flutter
* State Management: Riverpod / Bloc

Local Database:

* SQLite via Drift ORM

Backend:

* Supabase
* PostgreSQL Database
* Supabase Auth (future multi user)
* Supabase Storage (receipt images)

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
* Background sync to Supabase

Dashboard Calculation:

* Total balance = sum(wallet.balance)
* Monthly expense = sum(expense transaction)
* Budget remaining = limit − used

Budget Tracking:

* Query transactions by category + month
* Calculate usage percentage
* Trigger warning state if exceeded

---

## 5. Sync Mechanism

Sync Triggers:

* App launch
* Pull to refresh
* Background interval
* After transaction creation

Sync Strategy:

* Push local pending data
* Pull latest server data
* Update local database
* Handle duplicate via updated_at

Conflict Resolution:

* Latest update wins
* Soft delete using deleted_at field

---

## 6. Performance Requirements

* Transaction insert < 100ms
* Dashboard load < 500ms
* Sync under 3 seconds for 100 records

---

## 7. Security Requirements

* Row Level Security in Supabase
* User can access only own data
* JWT based authentication (future)

---

## 8. Future Scalability

Possible Features:

* Multi device realtime sync
* Recurring transactions
* Financial reports PDF export
* Spending prediction
* AI finance insights
* Bank integration API
