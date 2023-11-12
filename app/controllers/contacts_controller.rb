class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create ]
  before_action :set_contact, only: %i[ show edit update destroy ]
  before_action :load_cart
  before_action :load_orders


  def new
    @contact = Contact.new
  end


  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if verify_recaptcha(model: @contact) && @contact.save
        ContactMailer.contact(@contact).deliver_later
        format.html { redirect_to new_contact_url, notice: "Thank you for contacting me, I'll be in touch as soon as possible." }
        format.json { render :new, status: :created }
      elsif !verify_recaptcha(model: @contact)
        format.html do
          redirect_to new_contact_url, status: :unprocessable_entity, notice: "Please complete recaptcha 🤖"
        end
        format.json { render json: object.errors, status: :unprocessable_entity }
      else
        format.html { render :new, status: :unprocessable_entity, notice: "Something is missing 🤔" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    def set_contact
      @contact = Contact.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(:name, :email, :subject, :message)
    end

    def load_cart
      if session[:cart].nil?
        session[:cart] = []
        @cart = session[:cart]
      else
        @cart = Painting.find(session[:cart])
      end
    end

    def load_orders
      @orders = Order.all
    end

end
