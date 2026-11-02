# Turns an email into subscription facts using the first parser that knows the
# sender. Unknown senders return no facts (an LLM fallback can be plugged in).
module Receipts::Parser
  PARSERS = [ Receipts::AppleParser, Receipts::StripeParser ].freeze

  module_function

  def parse(email)
    parser = PARSERS.find { |p| p.handles?(email) }
    parser ? parser.parse(email) : []
  end
end
