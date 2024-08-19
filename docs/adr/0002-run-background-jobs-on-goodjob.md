# 2. Run background jobs on GoodJob, in-process

Date: 2024-08-19 · Status: accepted

## Context
The app needs a daily job (post recurring transactions), a monthly job (summary
emails) and ad-hoc mail delivery. Volume is low: a few jobs per user per day.
Sidekiq needs Redis and a separate worker process; Solid Queue was not yet released
as stable; `async` loses jobs on restart and has no cron.

## Decision
Use GoodJob with the Postgres database we already have, in `async` execution mode
(jobs run on threads inside the Puma process) and its built-in cron for schedules.

## Consequences
- One fewer service to run, pay for and back up; jobs are transactional with app data
  (a job enqueued in a rolled-back transaction never runs).
- Jobs compete with web requests for the same process. Fine at this scale; the move to
  a dedicated worker is a config change (`execution_mode: :external` + `good_job start`).
- Cron schedules live in `config/initializers/good_job.rb` and are covered by tests.
- Recurring posting is idempotent and row-locked, so overlapping runs after a restart
  or on multiple instances can't double-post.
