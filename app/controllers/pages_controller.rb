class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ home about cv photography]

  def home
  end

  def about
  end

  def cv
  end

  def photography
  end

end
