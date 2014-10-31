#!/bin/sh

if [ $# -ne 1 ]; then
	echo "Usage: watch.sh <command>" >&2
	exit 1
fi

$1 >stdout.txt 2>stderr.txt &

if [ $? -ne 0 ]; then
	echo "Failed to start command." >&2
	exit 1
fi

PID=$!
START_TIME="$(perl ./timestamp.pl)"
while :; do
	TIMESTAMP="$(echo "$(perl ./timestamp.pl) - $START_TIME" | bc)"
	RSS="$(ps -o 'rss=' -p $PID)"
	if [ $? -ne 0 ]; then
		break
	fi
	echo "$TIMESTAMP $RSS"
done
