class PaintingsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_painting, only: %i[ show edit update destroy ]

  def index
    @paintings = Painting.all
    session[:cart] ||= []
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

  def add_to_cart
    session[:cart] << params[:id]
    redirect_to paintings_path
  end

  def remove_from_cart
    session[:cart].delete(params[:id])
    redirect_to paintings_path
  end

  private
    def set_painting
      @painting = Painting.find(params[:id])
    end

    def painting_params
      params.require(:painting).permit(:description, :price, :title, :discount_code, photos: [])
    end
end
