# Finance Tracker

A personal finance app built with Ruby on Rails: track accounts, spending and budgets
in one place, import bank statements and see where your money goes.

> Started in 2021 as a course exercise, rebuilt from the ground up in 2024 on Rails 7.1
> and Hotwire.

![Dashboard](docs/screenshots/dashboard.png)

<table>
  <tr>
    <td><img src="docs/screenshots/transactions.png" alt="Transactions with filters and bulk actions"></td>
    <td><img src="docs/screenshots/reports.png" alt="Reports: cash flow, net worth, category breakdown"></td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/budgets.png" alt="Monthly budgets"></td>
    <td><img src="docs/screenshots/goals.png" alt="Savings goals"></td>
  </tr>
</table>

## Stack

- Ruby 3.3, Rails 7.1
- PostgreSQL
- Hotwire (Turbo + Stimulus) with import maps — no Node build step
- GoodJob for background jobs and cron (Postgres-backed, no Redis)
- Chartkick + Chart.js for charts
- Tailwind CSS (`tailwindcss-rails`)
- Minitest + Capybara

## Getting started

Requirements: Ruby 3.3.0 and PostgreSQL 14+.

```bash
git clone https://github.com/malikshoaib715/finance-tracker.git
cd finance-tracker
bin/setup        # installs gems, prepares the database
bin/dev          # runs the Rails server and the Tailwind watcher
```

No local Postgres? `docker compose up -d` starts one on port 5433; prefix the commands above with
`DATABASE_URL=postgres://postgres:postgres@localhost:5433`.

Then open http://localhost:3000 and sign in with the demo account created by the seeds:
`demo@example.com` / `password123`.

Emails (confirmation, password reset) open in the browser at http://localhost:3000/letter_opener.
Background jobs run on [GoodJob](https://github.com/bensheldon/good_job) inside the web process; its dashboard is at
http://localhost:3000/good_job in development.

## Deploying

The repo includes a [Render blueprint](render.yaml): a web service and a managed PostgreSQL database.
Background jobs run inside the web process (GoodJob async mode), so there is no worker to set up.

Set these environment variables on the service:

| Variable | Purpose |
|---|---|
| `RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc` |
| `APP_HOST` | Public host name, used in email links |
| `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | Outgoing email (any SMTP provider) |

The bundled `Dockerfile` works for any container host as well.

## Running the tests

```bash
bin/rails test          # models, controllers, integration
bin/rails test:system   # browser tests (headless Chrome)
bin/rubocop             # style
bin/brakeman            # security scan
```

## Features

- **Accounts** — cash, bank, cards, wallets and savings with running balances, reconciliation and archiving
- **Transactions** — categories, tags, notes, receipts (images/PDF), transfers between accounts, bulk edits
- **Filtering** — search, account/category/tag/type filters, month-by-month browsing, CSV export
- **Bank imports** — upload a statement CSV, map its columns, preview with duplicate detection, undo
- **Rules** — "description contains X → category Y", applied to new, imported and old transactions
- **Budgets** — monthly limits per category with progress bars and overspend warnings
- **Recurring transactions** — salary, rent and subscriptions posted automatically every day
- **Goals** — savings targets with the monthly amount needed to hit the date
- **Reports** — income vs expenses, category breakdown with month-over-month change, net worth
- **Multi-currency** — accounts in other currencies included via your own exchange rates
- **Monthly email** — a summary of last month on the 1st (opt-out in settings)
- **Quality of life** — quick add, keyboard shortcuts (`n`, `/`), installable PWA, lakh/crore grouping

See [ARCHITECTURE.md](ARCHITECTURE.md) for how it's built and [docs/API.md](docs/API.md) for the JSON API
that the mobile app uses.

## License

[MIT](LICENSE)

See [SECURITY.md](SECURITY.md) for the threat model and how to report a vulnerability.
