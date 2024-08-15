# JSON API (v1)

The API backs the mobile app and is available to any script. All responses are JSON;
amounts are integers in **minor units** (paisa/cents) and dates are ISO 8601.

## Authentication

Create a token under **Settings → API tokens**, or sign in from an app:

```bash
curl -X POST https://your-host/api/v1/session \
  -H 'Content-Type: application/json' \
  -d '{"email":"demo@example.com","password":"password123","device_name":"Pixel 8"}'
# => 201 {"token":"ft_…","user":{…}}
```

Send the token on every request:

```bash
curl https://your-host/api/v1/me -H 'Authorization: Bearer ft_…'
```

`DELETE /api/v1/session` revokes the token that made the request (sign out).
Tokens are stored as SHA-256 digests; a lost token can't be recovered, only revoked.

## Endpoints

| Method & path | Purpose |
|---|---|
| `POST /api/v1/session` | Sign in, returns a device token |
| `DELETE /api/v1/session` | Sign out (revoke the current token) |
| `GET /api/v1/me` | The signed-in user |
| `GET /api/v1/summary` | This month's income, spending, net worth and budgets |
| `GET /api/v1/accounts` | Accounts with current balances, in the user's order |
| `GET /api/v1/categories` | Income and expense categories |
| `GET /api/v1/transactions` | Changed transactions, oldest change first (see Sync) |
| `GET /api/v1/transactions/:id` | One transaction |
| `POST /api/v1/transactions` | Create (idempotent with `client_id`) |
| `PATCH /api/v1/transactions/:id` | Update |
| `DELETE /api/v1/transactions/:id` | Delete (leaves a tombstone) |
| `GET /api/v1/deletions?since=…` | Tombstones for deleted records |

### Creating a transaction

```bash
curl -X POST https://your-host/api/v1/transactions \
  -H 'Authorization: Bearer ft_…' -H 'Content-Type: application/json' \
  -d '{"transaction":{"client_id":"3f1c2b8e-8a8c-4f2e-9a51-0d9b8f1e2a77","kind":"expense",
       "amount_cents":125000,"occurred_on":"2024-08-15","description":"Careem",
       "account_id":3,"category_id":4,"tag_list":"work"}}'
```

- `201` with the transaction when created.
- `200` with the **same** transaction when `client_id` was already used (safe retries).
- `422` with `{"error":{"message":…,"details":{field:[…]}}}` on validation errors.
- `404` if the account or category isn't yours.

Categorisation rules apply when `category_id` is omitted.

## Sync

Offline clients keep a high-water mark and pull changes:

1. `GET /api/v1/transactions?updated_since=<last sync time>` — results are ordered by
   `(updated_at, id)`. If `next_cursor` is present, repeat with `?cursor=<next_cursor>`
   until it is `null`.
2. `GET /api/v1/deletions?since=<last sync time>` — remove those records locally.
3. Push local changes; use `client_id` on creates so a retry after a dropped connection
   never duplicates.
4. Store the time you started step 1 as the next high-water mark.

## Errors and limits

| Status | Meaning |
|---|---|
| `400` | Malformed parameter (e.g. a bad timestamp or cursor) |
| `401` | Missing, invalid or revoked token / wrong credentials |
| `404` | Not found (or not yours) |
| `422` | Validation failed — see `error.details` |
| `429` | Rate limited: 300 requests per 5 minutes per token; sign-in is throttled separately |
