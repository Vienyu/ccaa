#!/bin/sh
COMDIR=

if [ $2 -eq 1 ]; then
		mv "$3" "$COMDIR"
	fi
	echo [$(date)] $2, $3, $1 "<br>" >> /etc/ccaa/aria2_on_download_complete.log.html
