#!/bin/bash
### Functions to start FHEM ###

function StartFHEM {
	LOGFILE=/opt/fhem/log/system/fhem-%Y-%m-%d.log
	PIDFILE=/opt/fhem/log/system/fhem.pid
	SLEEPINTERVAL=0.5
	TIMEOUT="${TIMEOUT:-15}"
	CONFIGTYPE=${CONFIGTYPE:-"fhem.cfg"}
	
	echo
	echo '-------------------------------------------------------------------------------------------------------------------'
	echo
	echo "FHEM_VERSION = $FHEM_VERSION"
	echo "TZ = $TZ"
	echo "TIMEOUT = $TIMEOUT"
	echo "ConfigType = $CONFIGTYPE"
	echo
	echo '-------------------------------------------------------------------------------------------------------------------'
	echo
	
	## Function to print FHEM log in incremental steps to the docker log.
	test -f "$(date +"$LOGFILE")" && OLDLINES=$(wc -l < "$(date +"$LOGFILE")") || OLDLINES=0
	NEWLINES=$OLDLINES
	FOUND=false
	
	function PrintNewLines {
    	NEWLINES=$(wc -l < "$(date +"$LOGFILE")")
    	(( OLDLINES <= NEWLINES )) && LINES=$(( NEWLINES - OLDLINES )) || LINES=$NEWLINES
    	tail -n "$LINES" "$(date +"$LOGFILE")"
    	test ! -z "$1" && grep -q "$1" <(tail -n "$LINES" "$(date +"$LOGFILE")") && FOUND=true || FOUND=false
    	OLDLINES=$NEWLINES
	}

	## Docker stop sinal handler
	function StopFHEM {
		echo
		echo 'SIGTERM signal received, sending "shutdown" command to FHEM!'
		echo
		PID=$(<"$PIDFILE")
		perl /opt/fhem/fhem.pl 7072 shutdown
		echo 'Waiting for FHEM process to terminate before stopping container:'
		echo
		until $FOUND; do					## Wait for FHEM to shutdown
			sleep $SLEEPINTERVAL
            PrintNewLines "Server shutdown"
		done
		while ( kill -0 "$PID" 2> /dev/null ); do		## Wait for FHEM to end process
			sleep $SLEEPINTERVAL
		done
		PrintNewLines
		echo
		echo 'FHEM process terminated, stopping container. Bye!'
		exit 0
	}

	trap "StopFHEM" 0
	
	echo "Resetting 868MHz extension..."    
    #if test ! -d /sys/class/gpio/gpio17; then sudo echo 17 > /sys/class/gpio/export; fi
    #if test ! -d /sys/class/gpio/gpio18; then sudo echo 18 > /sys/class/gpio/export; fi
    #sudo echo out > /sys/class/gpio/gpio17/direction
    #sudo echo out > /sys/class/gpio/gpio18/direction
    #sudo echo 1 > /sys/class/gpio/gpio18/value
    #sudo echo 0 > /sys/class/gpio/gpio17/value
    #sleep 1
    #sudo echo 1 > /sys/class/gpio/gpio17/value
    #sleep 1
	
	if test ! -d /sys/class/gpio/gpio17; then sudo echo 17 > /sys/class/gpio/export; fi
sudo echo out > /sys/class/gpio/gpio17/direction
sudo echo 1 > /sys/class/gpio/gpio17/value
	
	cd /opt/fhem
	perl fhem.pl "$CONFIGTYPE"
	
	until $FOUND; do										## Wait for FHEM to start up
		sleep $SLEEPINTERVAL
        PrintNewLines "Server started"
	done
	
	PrintNewLines
	

	## Monitor FHEM during runtime
	while true; do
		if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")"; then					## FHEM isn't running
			PrintNewLines
			COUNTDOWN=$TIMEOUT
			echo
			echo "FHEM process terminated unexpectedly, waiting for $COUNTDOWN seconds before stopping container..."
			while ( [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")" ) && (( COUNTDOWN > 0 )); do	## FHEM exited unexpectedly
				echo "waiting - $COUNTDOWN"
				(( COUNTDOWN-- ))
				sleep 1
			done
			if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")"; then				## FHEM didn't reappeared
				echo '0 - Stopping Container. Bye!'
				exit 1
			else				## FHEM reappeared
				echo 'FHEM process reappeared, kept container alive!'
			fi
			echo
			echo 'FHEM is up and running again:'
			echo
		fi
		PrintNewLines			## Printing log lines in intervalls
		sleep $SLEEPINTERVAL
	done
}


### Start of Script ###

StartFHEM

#EOF