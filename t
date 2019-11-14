#!/bin/bash

#C="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
OPTS="--content-shell-host-window-size=800x600  --new-window"
URLS="https://trello.com/b/0l4YMdmM/dev https://trello.com/b/afTtSsCs/weekend https://trello.com/b/eJBSrKPg/conversations"

ps -ef | grep Chrome | grep -v Helper | grep -v grep > /dev/null 2>&1
running=$?

if [ $running -eq 1 ]; then 
   /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome > /dev/null 2>&1 &
   sleep 1
fi

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --start-fullscreen --new-window $URLS > /dev/null 2>&1 &

