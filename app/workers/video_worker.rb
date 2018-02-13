# app/workers/video_worker.rb
require 'sidekiq'
require 'fileutils'

class VideoWorker
include Sidekiq::Worker
sidekiq_options :retry => false

	def perform(root, video_count, user, images_count)
		puts "----------------Hello from sidekiq--------------------------", video_count
		puts "----------------Hello from sidekiq--------------------------"
		system 'ffmpeg -r 1/2 -i '+root+'/app/images_uploaded/'+user+'/temp_images'+images_count.to_s+'/image%02d.jpg -i '+root+'/app/images_uploaded/'+user+'/temp_images'+images_count.to_s+'/audio.mp3 '+root+'/app/images_uploaded/'+user+'/video_output%d.mp4 -hide_banner' % [video_count+1]
	  	FileUtils.remove_dir(root+'/app/images_uploaded/'+user+'/temp_images'+images_count.to_s)
	end

end
