class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ home about cv]

  def home
  end

  def about
  end

  def cv
  end
  
end
