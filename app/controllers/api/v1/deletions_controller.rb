class Api::V1::DeletionsController < Api::V1::BaseController
  def index
    since = params[:since].present? ? Time.iso8601(params[:since]) : Time.at(0)
    deletions = current_user.deletions.since(since).order(:deleted_at).limit(1000)
    render json: { deletions: deletions.map { _1.slice(:record_type, :record_id, :deleted_at) } }
  rescue ArgumentError
    render_error(:bad_request, "since must be an ISO 8601 time")
  end
end
