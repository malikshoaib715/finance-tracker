# Architecture

A short tour of how Finance Tracker is put together and why.

## Shape of the app

A conventional Rails 7.1 monolith: server-rendered HTML with Hotwire (Turbo +
Stimulus) for interactivity, Tailwind for styling, PostgreSQL for everything
— including the job queue. There is no Node build step: JavaScript is served
through import maps and Tailwind runs as a standalone binary.

```
Browser ── Turbo/Stimulus ──▶ Rails controllers ──▶ models / plain Ruby objects ──▶ PostgreSQL
                                     │
                                     └──▶ Active Job (GoodJob, in-process) ──▶ mailers, recurring transactions
```

## Data model

| Model | Purpose |
|---|---|
| `User` | Devise user with currency, time zone and display preferences |
| `Account` | Cash, bank, card, wallet or savings; opening balance + movements = balance |
| `Category` | Income or expense bucket with a colour; new users get a starter set |
| `Transaction` | One income or expense on an account; optional category, tags, receipts |
| `Transfer` | Money moved between two of the user's accounts (same currency) |
| `Budget` | Monthly limit for one expense category |
| `RecurringTransaction` | Template that posts transactions on a schedule |
| `Import` | An uploaded bank statement, its column mapping and outcome |
| `Rule` | "Description contains X → category Y" |
| `Goal` | Savings target, tracked by an account's balance or by hand |
| `ExchangeRate` | User-set rate from another currency into the default one |

Every record hangs off a user and every controller loads records through
`current_user` (`current_user.accounts.find(...)`), so one user can never reach
another's data. Models additionally validate that referenced accounts and
categories belong to the same user; controller tests cover the cross-user cases.

## Money

Amounts are stored as **integer minor units** (`amount_cents`, `bigint`) — never
floats. Forms accept major units ("1,250.50") through small `amount=` writers,
and `MoneyHelper#money` formats them back, including lakh/crore grouping for
users who prefer it. Transactions store a positive amount plus a `kind`
(`income`/`expense`); the sign is derived. Database check constraints back up
the model validations (positive amounts, distinct transfer accounts,
first-of-month budget dates).

## Where logic lives

- **Form/query objects** in `app/models` for anything that isn't a table:
  `TransactionFilter` (list filtering), `Account::Reconciliation`,
  `User::Onboarding`, `User::DataExport`.
- **Reports** (`app/models/reports/*`) are plain Ruby classes that each answer
  one question with a fixed number of queries: monthly cash flow, category
  breakdown, net worth.
- **Imports** are split into the `Import` record, `Import::Parser` (CSV → rows,
  amount/date parsing, duplicate detection) and `Import::Row`.
- **Recurring transactions** are posted by `RecurringTransaction::Generator`,
  which locks the row so concurrent runs can't double-post.

## Background work

GoodJob runs Active Job in the web process (`async` mode) on Postgres, with cron:

- `GenerateRecurringTransactionsJob` — daily, posts recurring transactions that fell due
- `SendMonthlySummariesJob` — on the 1st, emails last month's summary

No Redis, no separate worker process to deploy.

## Performance

- Lists that show balances or budget spending compute them in the same query
  (`Account.with_balances`, `Budget.with_spending`) instead of one SUM per row;
  tests pin the query counts.
- Bullet runs in development and **raises in tests**, so a new N+1 fails CI.
- Report chart **data** is cached on `User#finance_cache_version`, which
  changes whenever transactions, transfers, accounts, budgets or rates change.
  The HTML isn't cached because chart script tags carry a per-request CSP nonce.
- Indexes follow the queries (`[user_id, occurred_on]`, `[account_id, occurred_on]`,
  `[category_id, occurred_on]`); `strong_migrations` guards schema changes.

## Security

- Devise with confirmable and lockable (10 failed sign-ins locks for an hour).
- Rack::Attack throttles sign-in, sign-up and password-reset attempts.
- A nonce-based Content Security Policy: scripts only run from our origin or
  with the request's nonce (importmap and Chartkick add it); no inline handlers.
- Brakeman runs in CI; ignored warnings carry a note explaining why.
- Uploaded receipts are limited to images/PDFs under 5 MB; imports to 1 MB of CSV.

## Testing

Minitest throughout: model tests for rules and calculations, integration tests
for every controller (including "can't touch another user's record" cases) and
Capybara system tests for the flows that depend on JavaScript (category filter,
bulk actions, CSV import, keyboard shortcuts). CI runs Brakeman, RuboCop
(rails-omakase) and the full suite against Postgres on every push.
