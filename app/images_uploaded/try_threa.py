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
import shutil
import subprocess
import requests
from threading import Thread
import pycurl

stamp_found = False
found_frame = None
stamp = None
filepath = os.path.dirname(os.path.realpath(__file__))

def GetTimestamp(c_frame):
	text = pytesseract.image_to_string(Image.open("temp_vid/"+str(c_frame)+".bmp"))
	file = open("logfile.txt", "a")
	if len(text) > 0:
		m = re.findall("[0-2][0-9]:[0-5][0-9]:[0-5][0-9]:[0-9]{2}", text)
		if len(m) > 0:
			return (True, m[0])
		else:
			file.write(text.encode('ascii','ignore')+"\n")
			file.close()
			return (False, 'garbage')
	else:
		return (False, 'empty')


def getTimeFromFrameNumber(frame_no, fps):
	f = frame_no % fps
	s = int(frame_no/fps)
	m = int(s/60)
	s = s%60
	h = int(m/60)
	m = m%60
	s = s+float(f/fps)
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
	s = (isecs%3600)%60
	return (h,m,s,f)

def getBytes(url, begin, end, filename):
	global filepath
	#subprocess.call(["curl", "-o", filepath+"/"+filename, url, "-i", "-H", "Range: bytes="+begin+"-"+end], shell=False)
	c = pycurl.Curl()
	c.setopt(c.URL, url)
	c.setopt(c.HEADER, True)
	f = open(filename, 'w')
	c.setopt(c.WRITEFUNCTION, f.write)
	c.setopt(c.HTTPHEADER, ["Range: bytes="+str(begin)+"-"+str(end)])
	c.perform()
	f.close()
	return

def findStamp(start, end, bytes_per_frame, fps):
	global stamp_found, found_frame, stamp
	current_frame = start
	stamp_found_by_me = False
	while(stamp_found is False and current_frame < end):
		try:
			#h, m, s, f = getTimeFromFrameNumber(current_frame, fps)
			if not os.path.isfile('temp_vid/'+str(current_frame)+'.bmp'):
				getBytes(vid, str(current_frame*bytes_per_frame), str((current_frame+10)*bytes_per_frame), 'temp_vid/'+str(current_frame)+'.mpg')
				ff = FFmpeg(inputs={'temp_vid/'+str(current_frame)+'.mpg': None}, outputs={'temp_vid/'+str(current_frame)+'.bmp':'-loglevel 0 -vframes 1'})
				ff.run()
			t = GetTimestamp(current_frame)
			stamp_found_by_me = t[0]
			if stamp_found_by_me == True:
				stamp_found = True
		except FFRuntimeError:
			pass
		current_frame += fps*3
	if stamp_found_by_me is True:
		stamp = t[1]
		found_frame = current_frame-fps*3
		print "frame has been found"

if __name__ == '__main__':

	ap = argparse.ArgumentParser()
	ap.add_argument("-v", "--video", required=True, help="path to input video from which timestamp is to be extracted")
	args = vars(ap.parse_args())
	vid = str(args["video"])
	if not os.path.exists('temp_vid'):
		os.makedirs('temp_vid')
	
	capt = cv2.VideoCapture(args["video"])
	length = int(capt.get(cv2.CAP_PROP_FRAME_COUNT))
	fps = int(capt.get(cv2.CAP_PROP_FPS))
	capt.release()

	h_response = requests.head(vid)
	size = int(h_response.headers['content-length'])
	bytes_per_frame = int(size/length)
	t1 = Thread(target=findStamp, args=(0, int(length/4), bytes_per_frame, fps,))
	t1.start()
	t2 = Thread(target=findStamp, args=(int(length/4), int(length/2), bytes_per_frame, fps,))
	t2.start()
	t3 = Thread(target=findStamp, args=(int(length/2), int(3*length/4), bytes_per_frame, fps,))
	t3.start()
	t4 = Thread(target=findStamp, args=(int(length*3/4), length, bytes_per_frame, fps,))
	t4.start()
	print "finished calling all threads"
	#shutil.rmtree('temp_vid/')
	while stamp_found is False:
		pass
	time.sleep(2)
	if stamp_found is True:
		stamp_str=stamp.encode('ascii','ignore')
		print stamp_str, "timestamp of frame number", found_frame
		stamp = getTimeFirstFrame(stamp_str, found_frame, fps)
		print stamp, "stamp of first frame"


