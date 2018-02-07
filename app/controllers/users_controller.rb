class UsersController < ApplicationController

def new
	@user = User.new
end

def create
	@user = User.new(user_params)
  if @user.save
  	render 'registered'
  else
    render 'new'
end
end

def index
    @users = User.all
  end

private
def user_params
    params.require(:user).permit(:name, :dob, :password, :password_confirmation)
end
end
