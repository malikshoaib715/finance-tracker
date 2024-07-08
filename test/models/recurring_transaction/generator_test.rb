require "test_helper"

class RecurringTransaction::GeneratorTest < ActiveSupport::TestCase
  test "creates the due transaction and schedules the next one" do
    item = recurring_transactions(:rent)
    due = item.next_on

    created = RecurringTransaction::Generator.new(item).call

    assert_equal 1, created.size
    assert_equal [ due, 6_500_000, "Flat rent", "expense" ], created.first.values_at(:occurred_on, :amount_cents, :description, :kind)
    assert_equal due.next_month, item.reload.next_on
  end

  test "catches up on missed periods" do
    item = recurring_transactions(:rent)
    item.update!(next_on: Date.current << 3)

    assert_equal 4, RecurringTransaction::Generator.new(item).call.size
    assert_operator item.reload.next_on, :>, Date.current
  end

  test "stops and deactivates after the end date" do
    item = recurring_transactions(:rent)
    item.update!(next_on: Date.current << 2, ends_on: Date.current << 1)

    assert_equal 2, RecurringTransaction::Generator.new(item).call.size
    assert_not item.reload.active?
  end

  test "running twice doesn't duplicate" do
    item = recurring_transactions(:rent)
    RecurringTransaction::Generator.new(item).call
    assert_empty RecurringTransaction::Generator.new(item.reload).call
  end

  test "run_due handles every due item and skips paused ones" do
    assert_equal 1, RecurringTransaction::Generator.run_due
  end

  test "generated transactions remember where they came from" do
    created = RecurringTransaction::Generator.new(recurring_transactions(:rent)).call.first
    assert_equal recurring_transactions(:rent), created.recurring_transaction
    assert_equal "Recurring", created.source
  end
end
