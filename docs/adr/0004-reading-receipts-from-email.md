# 4. Reading subscription receipts from email

Date: 2026-11-02 · Status: accepted

## Context
Users rarely know everything they're subscribed to. Neither Apple nor Google lets an
app read the system subscription list, and bank statements show cryptic merchants
(`APPLE.COM/BILL`). Receipts in the user's inbox name the service, plan, price, card
and renewal date, and failed-payment emails show trouble early.

## Decision
Offer two ways in, both feeding the same pipeline (parse → facts → detector):

1. **Forwarding** — each user gets a private address `receipts-<token>@…`
   (Action Mailbox). Works with any email provider and needs no special API access.
2. **Connect Gmail** — OAuth with the read-only `gmail.readonly` scope; a daily job
   searches only known receipt senders since the last sync.

Privacy rules:
- Bodies are parsed in memory and dropped; only extracted facts are stored
  (service, amount, date, card last 4, and an evidence line of sender + subject).
- OAuth tokens are encrypted at rest (Active Record encryption).
- Disconnecting deletes the tokens and every fact learned from that mailbox.
- Parsers are per sender and deterministic; unknown senders are ignored rather than guessed.

## Consequences
- `gmail.readonly` is a **restricted scope**: a public launch needs Google's OAuth
  verification and an annual third-party security assessment (CASA). Until then the
  integration runs in testing mode (up to 100 named test users). Forwarding has no
  such requirement, so it is the default.
- Parsers break when senders change their templates; each has fixture-based tests
  with synthetic emails, and an LLM-based extractor for unknown senders is a possible
  extension behind the same `Receipts::Fact` interface.
- Detection is idempotent per message, so re-syncing or re-forwarding is safe.
