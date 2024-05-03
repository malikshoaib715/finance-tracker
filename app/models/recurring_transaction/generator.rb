# Creates the transactions that have fallen due for a recurring item,
# catching up on any missed periods, and moves next_on forward.
class RecurringTransaction::Generator
  MAX_CATCH_UP = 24

  def initialize(item, today: Date.current)
    @item = item
    @today = today
  end

  # Returns the transactions created. Safe to run concurrently: the row is
  # locked, and next_on is re-read inside the lock.
  def call
    @item.with_lock do
      created = []
      while @item.active? && @item.next_on <= @today && created.size < MAX_CATCH_UP
        break if @item.finished?

        created << create_transaction(@item.next_on)
        @item.next_on = @item.following(@item.next_on)
      end
      @item.active = false if @item.finished?
      @item.save!
      created
    end
  end

  def self.run_due(today: Date.current)
    RecurringTransaction.due(today).find_each.sum { |item| new(item, today:).call.size }
  end

  private

  def create_transaction(date)
    @item.user.transactions.create!(account: @item.account, category: @item.category, kind: @item.kind,
      amount_cents: @item.amount_cents, occurred_on: date, description: @item.description)
  end
end
