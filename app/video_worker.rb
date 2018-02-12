# app/workers/video_worker.rb
require 'sidekiq'

Sidekiq.configure_client do |config|
	config.redis = {db: 1}
end

Sidekiq.configure_server do |config|
	config.redis = {db: 1}
end

class VideoWorker
include Sidekiq::Worker

def perform(root, params, user)
	count = 01
	video_count = (Dir.entries(root.join('app', 'images_uploaded', user)).length)-2

	Dir.mkdir(root.join('app', 'images_uploaded', user, "temp_images"))
	params[:user][:picture].each do |uploaded_io|
	File.open(root.join('app', 'images_uploaded', user, 'temp_images', 'image%02d.jpg' % [count]), 'wb') do |file|
  	file.write(uploaded_io.read)
  	end
  	count += 1
  	end
	uploaded_audio = params[:user][:audio]

	File.open(Rails.root.join('app', 'images_uploaded', user, 'temp_images', 'audio.mp3'), 'wb') do |file|
  	file.write(uploaded_audio.read)
  	end
	system 'ffmpeg -r 1/2 -i '+Rails.root.join('app', 'images_uploaded', user, 'temp_images', 'image%02d.jpg').to_s+' -i '+Rails.root.join('app', 'images_uploaded', user, 'temp_images','audio.mp3').to_s+' '+Rails.root.join('app', 'images_uploaded', user, 'video_output%d.mp4' % [video_count+1]).to_s
  	FileUtils.remove_dir(Rails.root.join('app', 'images_uploaded', user, "temp_images"))
end

end