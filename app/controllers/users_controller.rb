require 'fileutils'
require 'zip'

class UsersController < ApplicationController

	def new
		@user = User.new
	end

	def show
		if logged_in? == true
			@user = @current_user
		video_count = (Dir.entries(Rails.root.join('public', 'images_uploaded', @current_user[:name])).length)-2
		end
	end

	def create
		@user = User.new(user_params)
		dir_path = "public/images_uploaded/#{@user[:name]}"
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

		count = 01
		video_count = 0
		images_count = 0
		Dir.entries(Rails.root.join('public', 'images_uploaded', @user[:name])).each do |entry|
			if entry.include? 'temp_images' then images_count += 1
			elsif entry.include? 'video_output' then video_count +=1
			end
		end

		Dir.mkdir(Rails.root.join('public', 'images_uploaded', @user[:name], "temp_images"+images_count.to_s))
		print params
		params[:picture].each do |uploaded_io|
		if uploaded_io.original_filename.include? '.zip'
			File.open(Rails.root.join('public', 'images_uploaded', @user[:name], 'temp_images'+images_count.to_s, uploaded_io.original_filename), 'wb') do |file|
	  		file.write(uploaded_io.read)
	  		end
	  	else
	  		File.open(Rails.root.join('public', 'images_uploaded', @user[:name], 'temp_images'+images_count.to_s, 'image%02d.jpg' % [count]), 'wb') do |file|
	  		file.write(uploaded_io.read)
	  		count += 1
	  		end
	  	end

	  	end
		uploaded_audio = params[:audio]
		File.open(Rails.root.join('public', 'images_uploaded', @user[:name], 'temp_images'+images_count.to_s, 'audio.mp3'), 'wb') do |file|
	  	file.write(uploaded_audio.read)
	  	end
		uploaded_text = params[:text]

	  	VideoWorker.perform_async(Rails.root.to_s, video_count, @current_user[:name], images_count, uploaded_text)
		render 'show'
	end

	def download_file
		filename = params[:filename]
		send_file filename , :disposition => 'attachment'
	end

	def videos
		current_user
		@user = @current_user
	end
	
	private
	def user_params
	    params.require(:user).permit(:name, :dob, :password, :password_confirmation)
	end

end
