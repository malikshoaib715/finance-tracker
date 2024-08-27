# Security

## Reporting a vulnerability

Please email **malik.shoaib715@gmail.com** rather than opening a public issue. Include
steps to reproduce; you'll get a reply within a few days.

## Threat model (summary)

What we protect: users' financial records, credentials and API tokens.

| Threat | Mitigation |
|---|---|
| One user reading or changing another's data | Every query is scoped through `current_user`; referenced accounts/categories are resolved through the user in controllers and re-validated in models; controller tests cover cross-user access for each resource |
| Credential stuffing / brute force | Rack::Attack throttles sign-in per IP and per email (web and API); Devise lockable locks after 10 failures; confirmable for new accounts |
| Stolen API token | Tokens are random (base58, 32 chars), stored only as SHA-256 digests, shown once, revocable from settings, rate-limited per token |
| XSS | ERB escaping by default; nonce-based Content Security Policy (no inline scripts or handlers); `frame-ancestors 'none'` |
| CSRF | Rails authenticity tokens on all web forms; the token-authenticated API uses no cookies |
| Malicious uploads | Receipts limited to images/PDF ≤ 5 MB and served by Active Storage; CSV imports ≤ 1 MB, parsed as data only |
| SQL injection | ActiveRecord bound parameters throughout; `LIKE` input is escaped with `sanitize_sql_like` |
| Vulnerable dependencies | Brakeman in CI; Dependabot weekly updates |
| Unsafe schema changes | strong_migrations; concurrent index builds; foreign keys validated separately |

## Not in scope (yet)

- Two-factor authentication
- Encryption of individual columns at rest (relies on the database/disk encryption of the host)
- Audit log of changes
