#!/bin/bash
gst-launch-1.0 -v \
 videotestsrc is-live=true pattern=ball ! \
 video/x-raw,width=640,height=480,framerate=30/1 ! \
 x264enc tune=zerolatency bitrate=2048 speed-preset=superfast ! \
 rtph264pay name=pay0 pt=96 ! \
 udpsink host=127.0.0.1 port=5000
