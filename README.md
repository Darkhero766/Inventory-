# Inventory — ElectroMart Electronics

Premium offline-first electronics shop inventory and POS application built with Flutter and SQLite.

## Core modules

- Premium retail-style Home, Inventory, Categories and Product catalog
- Category and brand-oriented product discovery
- Product pricing, margin, stock status, minimum stock and archive workflow
- Atomic stock ledger for purchases, sales, adjustments and opening stock
- Fast POS with Cash, UPI, Card, Bank Transfer and Credit payment choices
- Purchase receiving and supplier invoice records
- Customer and supplier directories
- Expenses and monthly books
- Inventory, sales, low-stock and monthly reporting views
- Warranty, dead-stock, users/permissions and notification surfaces
- Barcode scanner integration on supported mobile devices
- Professional printable sale invoice PDF
- CSV and Excel inventory export service
- Local SQLite database and demo-store seed data
- Responsive mobile bottom navigation and desktop navigation rail

## Demo store

The first run seeds ElectroMart Electronics with realistic Indian electronics categories, brands, products, suppliers, customers, stock movements and six months of transaction history.

Prices are demo values, not live market prices.

## Data integrity

Purchases and sales use SQLite transactions so inventory updates and ledger entries succeed or roll back together. Products with transaction history are archived rather than destructively deleted.

## Run

```bash
flutter pub get
flutter run
```

Android is the primary runtime. Desktop SQLite support requires the platform-specific sqflite FFI setup appropriate for the target desktop build.
