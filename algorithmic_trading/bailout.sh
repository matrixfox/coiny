#!/bin/sh

service="stop_loss.sh"

if ps -e | grep "$service"; then
    echo "running"
else
    echo "not running"
    /home/pi/coiny/stop_loss.sh
fi