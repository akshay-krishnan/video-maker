# public/workers/video_worker.rb
require 'sidekiq'
require 'fileutils'

class VideoWorker
include Sidekiq::Worker
sidekiq_options :retry => false

	def perform(root, video_count, user, images_count, text)
		if text.length > 1
			textlines = text.split('\n')
			full_drawtext_command = '"'
			drawtext1 = 'drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf: text='
			drawtext2 = ': fontsize=30: fontcolor=white: x=(w-text_w)/2: y=9*(h-text_h)/10: box=1: boxcolor=black: enable=\'between(t,'
			line_count =1 
			textlines.each do |line|
				puts line, '------------------------ this is the line-------------'
				if line.length > 2
					if line_count != textlines.length
						print '------------------------------- it is one of the lines'
					full_drawtext_command = full_drawtext_command + drawtext1+"'"+line.split(': ')[1]+"'"+drawtext2+line.split(": ")[0]+")',"
					else
						print '---------------------------- it is the last line'
					full_drawtext_command = full_drawtext_command+ drawtext1+"'"+line.split(': ')[1]+"'"+drawtext2+line.split(": ")[0]+")'"
					end
				end
				line_count += 1
			end
		end
		full_drawtext_command = full_drawtext_command+'"'
		count = 0
		Dir.entries(root+'/public/images_uploaded/'+user+'/temp_images'+images_count.to_s).each do |db|
		if db.include? '.zip'
			Zip::File.open(root+'/public/images_uploaded/'+user+'/temp_images'+images_count.to_s+'/'+db) do |zipfile|
				zipfile.each do |entry|
					entry.extract(root+'/public/images_uploaded/'+user+'/temp_images'+images_count.to_s+'/image%02d.jpg' % [count])
					count += 1
				end
			end
		end
	end
		puts "----------------Hello from sidekiq--------------------------", video_count
		puts "----------------Hello from sidekiq--------------------------"

		cmd = 'ffmpeg -r 1/2 -i '+root+'/public/images_uploaded/'+user+'/temp_images'+images_count.to_s+'/image%02d.jpg -i '+root+'/public/images_uploaded/'+user+'/temp_images'+images_count.to_s+'/audio.mp3 -vf '+full_drawtext_command+' '+root+'/public/images_uploaded/'+user+'/video_output%d.mp4 -hide_banner' % [video_count+1]
		puts cmd

		system cmd
		FileUtils.remove_dir(root+'/public/images_uploaded/'+user+'/temp_images'+images_count.to_s)
	end

end
