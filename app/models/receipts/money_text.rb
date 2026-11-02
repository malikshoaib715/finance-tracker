# Pulls amounts like "Rs 1,100.00", "PKR 899", "$20.00", "USD 93.68" out of text.
module Receipts::MoneyText
  SYMBOLS = { "$" => "USD", "€" => "EUR", "£" => "GBP", "Rs" => "PKR", "Rs." => "PKR" }.freeze
  PATTERN = /(?<code>PKR|USD|EUR|GBP|AED|SAR|Rs\.?|\$|€|£)\s?(?<amount>\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)/

  module_function

  # [amount_cents, currency] for the first amount in +text+, or nil.
  def first(text)
    match = PATTERN.match(text.to_s) or return
    [ (BigDecimal(match[:amount].delete(",")) * 100).round, SYMBOLS.fetch(match[:code], match[:code]) ]
  end

  # "Visa •••• 8685", "Mastercard - 1922", "card ending in 4792"
  def card_last4(text)
    text = text.to_s
    text[/(?:•|\*|ending in|ending)\s*(?:•|\*|\s)*(\d{4})\b/i, 1] ||
      text[/\b(?:Visa|Mastercard|MasterCard|Amex|American Express|Discover|UnionPay)\b\D{0,12}?(\d{4})\b/, 1]
  end
end
