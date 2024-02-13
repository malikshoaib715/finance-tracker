module MoneyHelper
  CURRENCY_UNITS = {
    "PKR" => "Rs ", "USD" => "$", "EUR" => "€", "GBP" => "£", "AED" => "AED ", "SAR" => "SAR "
  }.freeze

  # Amounts are stored as integer minor units (paisa, cents) to avoid float rounding.
  #
  #   money(1_234_50, "PKR")  # => "Rs 1,234.50"
  #   money(-500, "USD")      # => "-$5.00"
  def money(amount_cents, currency = current_user&.currency || "PKR")
    number_to_currency(amount_cents.to_i / 100.0,
      unit: CURRENCY_UNITS.fetch(currency, "#{currency} "),
      negative_format: "-%u%n")
  end

  # Colour amounts by sign, e.g. income green and expenses red.
  def money_tag(amount_cents, currency = nil, **options)
    css = amount_cents.to_i.negative? ? "text-rose-600" : "text-emerald-700"
    tag.span money(amount_cents, *currency), **options, class: [ "tabular-nums", css, options[:class] ]
  end
end
