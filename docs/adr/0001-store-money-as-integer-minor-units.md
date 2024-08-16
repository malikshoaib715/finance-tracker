# 1. Store money as integer minor units

Date: 2024-08-16 · Status: accepted

## Context
Balances are sums of many amounts. Floating point can't represent most decimal
fractions exactly (0.1 + 0.2 ≠ 0.3), and errors accumulate across thousands of rows.
`decimal` columns are exact but make every calculation and JSON payload carry
string-encoded decimals, and the app has no use for sub-paisa precision.

## Decision
Every amount is a `bigint` of minor units (`amount_cents`, `opening_balance_cents`, …).
Transactions store a positive amount and a `kind`; the sign is derived. Conversion to
and from major units happens only at the edges: form writers (`amount=`) and the
`money` view helper. Check constraints reject non-positive amounts at the database.

## Consequences
- Sums and comparisons are exact integer arithmetic in Ruby and SQL.
- The API exposes integers, which every client language handles without precision loss.
- Currencies with three decimals (e.g. KWD) would need a per-currency exponent — not
  needed for the supported currencies, and a contained change if it ever is.
- Aggregates computed in SQL come back as `numeric` and must be cast (`to_i`) before
  serialising; tests cover the JSON shape.
