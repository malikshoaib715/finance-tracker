class ApplicationMailbox < ActionMailbox::Base
  # receipts-<token>@<INBOUND_DOMAIN> — each user's private forwarding address.
  routing(/\Areceipts-[a-z0-9]+@/i => :receipts)
end
