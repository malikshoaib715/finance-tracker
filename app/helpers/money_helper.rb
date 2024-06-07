module MoneyHelper
  CURRENCY_UNITS = {
    "PKR" => "Rs ", "USD" => "$", "EUR" => "€", "GBP" => "£", "AED" => "AED ", "SAR" => "SAR "
  }.freeze

  # Amounts are stored as integer minor units (paisa, cents) to avoid float rounding.
  #
  #   money(1_234_50, "PKR")  # => "Rs 1,234.50"
  #   money(-500, "USD")      # => "-$5.00"
  def money(amount_cents, currency = money_user&.currency || "PKR")
    unit = CURRENCY_UNITS.fetch(currency, "#{currency} ")

    if money_user&.numbers_south_asian?
      sign = amount_cents.to_i.negative? ? "-" : ""
      "#{sign}#{unit}#{south_asian_digits(amount_cents.to_i.abs)}"
    else
      number_to_currency(amount_cents.to_i / 100.0, unit: unit, negative_format: "-%u%n")
    end
  end

  # Whose preferences to format for: the signed-in user in views, @user in mailers.
  def money_user
    (current_user if respond_to?(:current_user)) || @user
  end

  # 12345678 (cents) -> "1,23,456.78": the last three digits, then pairs (lakh, crore).
  def south_asian_digits(cents)
    whole, fraction = cents.divmod(100)
    digits = whole.to_s
    head, tail = digits[0...-3], digits[-3..] || digits
    head = head.reverse.scan(/\d{1,2}/).join(",").reverse
    [ head.presence, tail ].compact.join(",") + format(".%02d", fraction)
  end

  # Colour amounts by sign, e.g. income green and expenses red.
  def money_tag(amount_cents, currency = nil, **options)
    css = amount_cents.to_i.negative? ? "text-rose-600" : "text-emerald-700"
    tag.span money(amount_cents, *currency), **options, class: [ "tabular-nums", css, options[:class] ]
  end
end
