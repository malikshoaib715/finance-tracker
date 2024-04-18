# One statement line turned into the attributes of a transaction.
class Import::Row
  attr_reader :line, :occurred_on, :description, :amount_cents, :kind, :errors
  attr_accessor :duplicate

  def initialize(line:, occurred_on:, description:, amount_cents:, errors:)
    @line = line
    @occurred_on = occurred_on
    @description = description
    @amount_cents = amount_cents&.abs
    @kind = amount_cents.to_i.negative? ? "expense" : "income"
    @errors = errors
  end

  def valid? = errors.empty?
  def duplicate? = !!duplicate
  def importable? = valid? && !duplicate?

  def signed_amount_cents
    kind == "income" ? amount_cents : -amount_cents
  end
end
