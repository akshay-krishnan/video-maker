class SessionsController < ApplicationController

  def new
  end

  def create
  	user = User.find_by(name: params[:session][:name])
  	@error_found = nil
  	if user && user.authenticate(params[:session][:password])
  		puts "LOGIN ACCEPTED"
  		log_in user
  		redirect_to user
  	else
  		puts "LOGIN REJECTED"
        @error_found = true
        render 'new'
  	end
  end

  def destroy
    log_out
    redirect_to root_url
  end

end
