#!/bin/sh

#
# get all warpx process PIDs
#
kill_pids="`ps -ax|grep warpx|sed '/grep/d'|awk '{print $1}'`"

# remove blanks before or after the PIDs
kill_pids="`echo $kill_pids`"

echo "kill_pids=$kill_pids"

for pid in $kill_pids; do
    echo "Kill $pid"
    sudo kill $pid 2>/dev/zero
done

sudo killall pcm-latency 2>/dev/zero
sudo killall pcm-memory 2>/dev/zero

ps -ax|grep warpx
ps -ax|grep pcm

echo "Finished"
