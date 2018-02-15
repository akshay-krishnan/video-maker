import cv2
import numpy as np
import time
from PIL import Image
import pytesseract
import argparse
import os
from ffmpy import FFmpeg
import re
import unicodedata


def GetTimestamp(video):
	cap = cv2.VideoCapture(video)
	filename = "{}.bmp".format(os.getpid())
	stamp_found = False
	frame_count = 0
	while(cap.isOpened() and stamp_found is False):
		ret, frame = cap.read()
		if ret == True:
			cv2.imwrite(filename, frame)
			text = pytesseract.image_to_string(Image.open(filename))
			if len(text) > 0:
				m = re.findall("[0-2][0-9].[0-5][0-9].[0-5][0-9].[0-9][0-9]", text)
				if len(m) > 0:
					print m
					stamp =  m[0].encode('ascii','ignore')
					s = list(stamp)
					st = []
					for item in s:
						if item.isdigit() == True:
							st.append(item)
					if len(st) == 8:
						stamp_found = True
						print stamp, "---------------"
						j = st[0]+st[1]+':'+st[2]+st[3]+':'+st[4]+st[5]+':'+st[6]+st[7]
						stamp = j 	
					print stamp, getTimeFirstFrame(stamp, frame_count, 25)
				else:
					gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
					rows, cols =  gray.shape
					gray = gray[20:40, int(float(cols/3))+18:int(float(cols)*2/3)-16]
					gray = cv2.threshold(gray, 230,255,cv2.THRESH_BINARY)[1]
					cv2.imshow('win', gray)
					cv2.waitKey(1)
					cv2.imwrite(filename, gray)
					text = pytesseract.image_to_string(Image.open(filename))
					os.remove(filename)
					if len(text) > 0:
						m = re.findall("[0-2][0-9].[0-5][0-9].[0-5][0-9].[0-9][0-9]", text)
						if len(m) > 0:
							print m
							stamp =  m[0].encode('ascii','ignore')
							s = list(stamp)
							st = []
							for item in s:
								if item.isdigit() == True:
									st.append(item)
							if len(st) == 8:
								stamp_found = True
								print stamp, "---------------"
								j = st[0]+st[1]+':'+st[2]+st[3]+':'+st[4]+st[5]+':'+st[6]+st[7]
								stamp = j 	
							print stamp, getTimeFirstFrame(stamp, frame_count, 25)
			frame_count += 1		
		else:
			break
	cap.release()
	return stamp_found, stamp, frame_count


def getTimeFromFrameNumber(frame_no, fps):
	f = frame_no % fps
	s = int(frame_no/fps)
	m = int(s/60)
	s = s%60
	h = int(m/60)
	m = m%60
	return (h, m, s, f)

def getTimeFirstFrame(stamp, frameno, fps):
	l = stamp.split(':')
	t = []
	for i in l:
		t.append(int(i))
	h,m,s,f = t
	secs = h*3600 + m*60 + s
	isecs = secs - (frameno/fps)
	h = isecs/3600
	m = (isecs%3600)/60
	s = (isecs%60)
	return (h,m,s,0)


if __name__ == '__main__':
	ap = argparse.ArgumentParser()
	ap.add_argument("-v", "--video", required=True, help="path to input video from which timestamp is to be extracted")
	args = vars(ap.parse_args())

	# if not os.path.exists('temp_vid'):
	# 	os.makedirs('temp_vid')
	
	# capt = cv2.VideoCapture(args["video"])
	# length = int(capt.get(cv2.CAP_PROP_FRAME_COUNT))
	# fps = int(capt.get(cv2.CAP_PROP_FPS))
	# capt.release()

	# global stamp_found
	# stamp_found = False

	# current_frame = 0
	# while(stamp_found is False and current_frame < length):
	# 	h, m, s, f = getTimeFromFrameNumber(current_frame, fps)	
	# 	if not os.path.isfile('temp_vid/vid'+str(current_frame)+'.mpg'):
	# 		ff = FFmpeg(inputs={args["video"]: None}, outputs={'temp_vid/'+str(current_frame)+'.mpg':'-ss '+'%02d'%h+':'+'%02d'%m+':'+'%02d'%s+' -codec copy -t 1'})
	# 		ff.run()
	# 	t = GetTimestamp(current_frame)
	# 	print t
	# 	stamp_found = t[0]
	# 	current_frame += fps*5
	print "called function"	
	GetTimestamp(args["video"])
	print "returned"
