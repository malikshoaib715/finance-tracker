# Finance Tracker

A personal finance app built with Ruby on Rails: track accounts, spending and budgets
in one place, import bank statements and see where your money goes.

> Started in 2021 as a course exercise, rebuilt from the ground up in 2024 on Rails 7.1
> and Hotwire.

## Stack

- Ruby 3.3, Rails 7.1
- PostgreSQL
- Hotwire (Turbo + Stimulus) with import maps — no Node build step
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

Then open http://localhost:3000 and sign in with the demo account created by the seeds:
`demo@example.com` / `password123`.

Emails (confirmation, password reset) open in the browser at http://localhost:3000/letter_opener.

## Running the tests

```bash
bin/rails test
```

## Roadmap

- [x] User accounts and authentication
- [ ] Accounts (cash, bank, card, wallet) with balances
- [ ] Categories and transactions
- [ ] Monthly budgets with overspend alerts
- [ ] Dashboard charts and reports
- [ ] CSV import from bank statements
- [ ] Recurring transactions
