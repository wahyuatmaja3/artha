# PRODUCT REQUIREMENT DOCUMENT

## Product Name: Personal Budgeting Mobile App (Budggt Style)

## 1. Overview

A mobile application that helps users track income, expenses, manage budgets, and monitor financial habits.
The app focuses on simplicity, clean UI, and fast daily financial input.

Target user:

* Individual users
* Students / workers
* People who want simple budgeting
* Not for accounting professionals

Platform:

* Android (Flutter)

---

## 2. Main Navigation Structure

Bottom Navigation:

1. Dashboard
2. Transactions
3. Add Transaction (Floating Button)
4. Budget
5. Profile / Settings

---

## 3. Dashboard Screen

Purpose:

* Show financial overview

Components:

* Total Balance Card
  Shows sum of all wallets

* Monthly Spending Summary
  Shows total expense this month

* Budget Remaining Card
  Shows remaining usable money

* Expense Chart
  Pie chart by category

* Recent Transactions List
  Last 5 transactions

* Quick Add Button

Behavior:

* Pull to refresh
* Tap wallet → open wallet detail
* Tap chart category → open filtered transaction list

---

## 4. Transaction List Screen

Purpose:

* View all financial records

Features:

* List grouped by date
* Expense color: red
* Income color: green
* Search transaction
* Filter by:

  * Category
  * Wallet
  * Date range
  * Type (income / expense)

Interaction:

* Swipe left → delete
* Swipe right → edit
* Tap → open detail page

---

## 5. Add Transaction Screen

Fields:

* Amount (numeric keyboard)
* Type toggle (Income / Expense)
* Category picker
* Wallet picker
* Date picker
* Note text input

Optional:

* Attach receipt image

Behavior:

* Save → return to dashboard
* Auto update balance
* Auto update budget usage

---

## 6. Budget Screen

Purpose:

* Manage monthly budget

Features:

* List budget per category
* Progress bar per category
* Remaining amount display
* Add new budget
* Edit budget
* Delete budget

Additional:

* Warning indicator when limit exceeded
* Monthly reset logic

---

## 7. Wallet Management Screen

Features:

* Create wallet (Cash / Bank / E-Wallet)
* Edit wallet name
* Set initial balance
* View wallet transaction history
* Delete wallet (if no transaction)

---

## 8. Profile / Settings Screen

Features:

* Currency setting
* Dark mode toggle
* Backup / sync indicator
* Data export (future feature)
* App info

---

## 9. UX Style

* Minimalist layout
* Card based UI
* Soft colors
* Big readable typography
* Floating Action Button for quick input
* Smooth transitions
* Fast loading

---

## 10. Non Functional Requirements

* Offline first experience
* Sync when internet available
* Fast input (< 2 seconds)
* Lightweight memory usage
* Responsive layout
