require 'fileutils'

class UsersController < ApplicationController

def new
	@user = User.new
end

def show
	if logged_in? == true
		@user = @current_user
	end
	video_count = (Dir.entries(Rails.root.join('app', 'images_uploaded', @current_user[:name])).length)-2
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
	@user = @current_user
	# count = 01
	# video_count = (Dir.entries(Rails.root.join('app', 'images_uploaded', @current_user[:name])).length)-2

	# Dir.mkdir(Rails.root.join('app', 'images_uploaded', @current_user[:name], "temp_images"))
	# params[:user][:picture].each do |uploaded_io|
	# File.open(Rails.root.join('app', 'images_uploaded', @current_user[:name], 'temp_images', 'image%02d.jpg' % [count]), 'wb') do |file|
 #  	file.write(uploaded_io.read)
 #  	end
 #  	count += 1
 #  	end
	# uploaded_audio = params[:user][:audio]

	# File.open(Rails.root.join('app', 'images_uploaded', @current_user[:name], 'temp_images', 'audio.mp3'), 'wb') do |file|
 #  	file.write(uploaded_audio.read)
 #  	end
	# system 'ffmpeg -r 1/2 -i '+Rails.root.join('app', 'images_uploaded', @current_user[:name], 'temp_images', 'image%02d.jpg').to_s+' -i '+Rails.root.join('app', 'images_uploaded', @current_user[:name], 'temp_images','audio.mp3').to_s+' '+Rails.root.join('app', 'images_uploaded', @current_user[:name], 'video_output%d.mp4' % [video_count+1]).to_s
 #  	FileUtils.remove_dir(Rails.root.join('app', 'images_uploaded', @current_user[:name], "temp_images"))
  	VideoWorker.perform_async(Rails.root, params, @current_user[:name])
  	render 'show'
end

def download_file
	filename = params[:filename]
	send_file filename , :disposition => 'attachment'
  	
end

private
def user_params
    params.require(:user).permit(:name, :dob, :password, :password_confirmation)
end

end
