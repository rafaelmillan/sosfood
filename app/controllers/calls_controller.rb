class CallsController < ApplicationController
  skip_before_action :authenticate_user!, only: :receive
  skip_before_action :verify_authenticity_token, only: :receive
  skip_after_action :verify_authorized, only: :receive

  def receive
    respond_to do |format|
      format.json do
        render json: CallService.new(call).generate_response(params["command_result"].to_i)
      end
    end
  end

  private

  def call
    Call.create_with(recipient: recipient).find_or_create_by(callr_id: params["callid"].to_i)
  end

  def recipient
    Recipient.find_or_create_by(phone_number: params["cli_number"])
  end
end
