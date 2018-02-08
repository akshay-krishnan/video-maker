class UsersController < ApplicationController

def new
	@user = User.new
end

def show
	if logged_in? == true
		@user = @current_user
	end
end

def create
	@user = User.new(user_params)
	dir_path = "app/images_uploaded/#{@user[:name]}"
	Dir.mkdir dir_path
  if @user.save && (Dir.exists?(dir_path))
  	render 'registered'
  else
    render 'new'
end
end

def index
    @users = User.all
  end

def update
	current_user
	#uploaded_io = params[:user][:picture]
	params[:user][:picture].each do |uploaded_io|
	File.open(Rails.root.join('app', 'images_uploaded', @current_user[:name],uploaded_io.original_filename), 'wb') do |file|
  	file.write(uploaded_io.read)
  	end
  	end
  	redirect_to @current_user
end

private
def user_params
    params.require(:user).permit(:name, :dob, :password, :password_confirmation)
end

end
