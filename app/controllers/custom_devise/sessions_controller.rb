class CustomDevise::SessionsController < Devise::SessionsController
  class CustomDevise::SessionsController < Devise::SessionsController

    def create
      user = User.find_by(email: params[:user][:email])
      if user && user.email == ENV['EMAIL']
        super # Call the default create method from Devise
      else
        flash[:alert] = 'Login is restricted to only the artist.'
        redirect_to root_path
      end
    end
  end

end
