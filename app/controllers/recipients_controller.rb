class RecipientsController < ApplicationController

  def new
  end

  def subscribe

    if Recipient.find_by(phone_number: params[:phone_number])
      recipient = Recipient.find_by(phone_number: params[:phone_number])
      recipient.subscribed = true
      recipient.save
    else #si mon user n'existe pas je crée un new user
      recipient = Recipient.new(suscribed: :true, phone_number: :phone_number, address: :address )
      #je change son statut à suscribed
      #j'attribue un numero de telephone au user
      #j'attribue une lat et une long au user
      #je le save
      recipient.save
    end


    end
  end

