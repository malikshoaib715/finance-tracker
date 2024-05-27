class Users::DataExportsController < ApplicationController
  def show
    send_data JSON.pretty_generate(User::DataExport.new(current_user).as_json),
      filename: "finance-tracker-#{Date.current.iso8601}.json", type: :json
  end
end
