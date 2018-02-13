# app/workers/video_worker.rb
require 'sidekiq'
require 'fileutils'

require "byebug"



Sidekiq.configure_server do |config|
 	config.redis = {url: "redis://127.0.0.1:6379/0"}
end

class VideoWorker
	include Sidekiq::Worker

	def perform(root, video_count, user)
		byebug
		puts "-----------------------hello there from sidekiq---------------------------------------"
		sleep(10)
		system 'ffmpeg -r 1/2 -i '+root+'/app/images_uploaded/'+user+'/temp_images/image%02d.jpg -i '+root+'app/images_uploaded/'+user+'/temp_images/audio.mp3 'root+'app/images_uploaded/user/video_output%d.mp4' % [video_count+1]
	end

end
