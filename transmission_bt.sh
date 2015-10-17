#!/bin/bash

function usage {
    echo "Usage: $0 OPTIONS

OPTIONS:
   -b			  Start Transmission BT client
   -e			  Stop Transmission BT client
   -r			  Reload settings
   -y			  Restart Transmission BT client"
}


function get_PID {
    echo `ps aux | grep -i transmission | grep -v -E "tail|vim|grep|bash|launchctl" | awk ' {print $2} '`
}

function stop_tbt {
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.transmission.plist
    sleep 1
    TBT_PID=$(get_PID)
    if [ -z "$TBT_PID" ]; then
        echo "Transmission successfully stopped"
    else
        echo "Transmission was not stopped."
        echo "Try running the command manually or kill the PID: $TBT_PID"
        echo "launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.transmission.plist"
    fi
}

function start_tbt {
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.transmission.plist
    sleep 1
    TBT_PID=$(get_PID)
    if [ -z "$TBT_PID" ]; then
        echo "Transmission failed to start."
        echo "Try running the command manually:"
        echo "launchctl load ~/Library/LaunchAgents/homebrew.mxcl.transmission.plist"
    else
        echo "Transmission started successfully with PID: $TBT_PID"
    fi
}

while getopts "ber:yh" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		b)
			START=1
			;;
		e)
			STOP=1
			;;
        r)
            RELOAD=1
            ;;
        y)
            RESTART=1
            ;;
		?)
			usage
			exit 1
			;;
	esac
done

if [ -n "$START" ]; then
    start_tbt

elif [ -n "$STOP" ]; then
    stop_tbt

elif [ -n "$RELOAD" ]; then
    if [[ $OSTYPE =~ "darwin" ]]; then
        pkill -HUP transmission-da
    else
        killall -HUP transmission-da
    fi
    sleep 1
    echo "Settings reloaded"

elif [ -n "$RESTART" ]; then
    stop_tbt
    start_tbt

else
	usage
	exit 1
fi
