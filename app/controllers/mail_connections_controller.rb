class MailConnectionsController < ApplicationController
  # OmniAuth callback after the user grants read-only Gmail access.
  def create
    auth = request.env.fetch("omniauth.auth")
    connection = current_user.mail_connection || current_user.build_mail_connection
    connection.update!(
      provider: "google", email: auth.info.email,
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token.presence || connection.refresh_token,
      expires_at: auth.credentials.expires_at && Time.zone.at(auth.credentials.expires_at),
      last_error: nil
    )
    GmailSyncJob.perform_later(connection.id) if defined?(GmailSyncJob)
    redirect_to subscriptions_path, notice: "Connected #{connection.email}. Looking for receipts…"
  end

  # Disconnect: forget the tokens and everything learned from that mailbox.
  def destroy
    connection = current_user.mail_connection
    if connection
      SubscriptionEvent.joins(:subscription).where(subscriptions: { user_id: current_user.id }, source: "gmail").delete_all
      current_user.subscriptions.where.missing(:events).destroy_all
      connection.destroy!
    end
    redirect_to subscriptions_path, notice: "Gmail disconnected and its data removed.", status: :see_other
  end

  def failure
    redirect_to subscriptions_path, alert: "Gmail wasn't connected: #{params[:message].to_s.humanize}."
  end
end
