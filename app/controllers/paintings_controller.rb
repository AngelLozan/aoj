class PaintingsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show add_to_cart remove_from_cart]
  before_action :set_painting, only: %i[ show edit update destroy ]
  before_action :initalize_cart, only: %i[load_cart add_to_cart remove_from_cart ]
  before_action :load_cart, only: %i[ index show add_to_cart remove_from_cart ]

  def index
    @paintings = Painting.all
  end

  def show
  end

  def new
    @painting = Painting.new
  end

  def edit
  end

  def create
    adjusted_params = painting_params.merge(price: (painting_params[:price].to_f * 100).to_i)
    @painting = Painting.new(adjusted_params)
    respond_to do |format|
      if @painting.save
        format.html { redirect_to painting_url(@painting), notice: "Painting was successfully created." }
        format.json { render :show, status: :created, location: @painting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @painting.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @painting.update(painting_params)
        format.html { redirect_to painting_url(@painting), notice: "Painting was successfully updated." }
        format.json { render :show, status: :ok, location: @painting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @painting.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @painting.destroy
    respond_to do |format|
      format.html { redirect_to paintings_url, notice: "Painting was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def admin
    @paintings = Painting.all
  end

  # @dev Cart functionality

  # @dev only display cart if the painting isn't in cart already (not etsy)
  def load_cart
    if session[:cart].nil?
      session[:cart] = []
      @cart = session[:cart]
    else
      @cart = Painting.find(session[:cart])
    end
  end

  def add_to_cart
    id = params[:id].to_i
    session[:cart] << id unless session[:cart].include?(id)
    redirect_to paintings_path
  end

  def remove_from_cart
    id = params[:id].to_i
    session[:cart].delete(id)
    redirect_to paintings_path
  end

  private
    def set_painting
      @painting = Painting.find(params[:id])
    end

    def painting_params
      params.require(:painting).permit(:description, :price, :title, :discount_code, photos: [])
    end

    def initalize_cart
      session[:cart] ||= []
    end
end
