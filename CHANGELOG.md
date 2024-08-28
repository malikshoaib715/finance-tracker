# Changelog

## 1.0.0 — 2024-08-30

First complete release of the 2024 rebuild.

### Web app
- Accounts (cash, bank, card, wallet, savings) with balances, archiving, ordering and reconciliation
- Transactions with categories, tags, notes, receipts, transfers, bulk edits and quick add
- Filters, month-by-month browsing, CSV export and keyboard shortcuts
- Bank statement import: column mapping, preview, duplicate detection and undo
- Categorisation rules applied to new, imported and existing transactions
- Monthly budgets with warnings; recurring transactions; savings goals
- Reports: cash flow, category breakdown, net worth (multi-currency), year in review
- Monthly summary email; installable PWA with offline page; lakh/crore number grouping

### API (for the mobile app)
- Token authentication and email/password device sign-in
- Accounts, categories, monthly summary
- Transactions change feed with cursor paging, tombstones, idempotent creates and conflict detection

### Engineering
- Rails 7.1, Hotwire, Tailwind, PostgreSQL, GoodJob
- Security: Devise confirmable/lockable, Rack::Attack, CSP, Brakeman in CI
- Performance: single-query balances and budget spending, Bullet in tests, tuned indexes, cached report data
- 240 tests (92% line coverage) plus browser tests; CI runs security scan, lint and tests
- Architecture notes, ADRs, API docs, threat model, Render blueprint

## 0.1.0 — 2021-01-07
- Course exercise scaffold (Rails 6.0)
