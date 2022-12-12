#!/bin/bash

###############################################################################
# declare constants for easier later changes
###############################################################################

readonly MQTT_DNS=192.168.178.114
readonly MQTT_PORT=1883


###############################################################################
# setup defaults for options
###############################################################################

DELAY=10
MQTT_CONFIG='/mqtt/topic/description'

###############################################################################
# display usage information
###############################################################################

usage() {

echo "\
Usage: speedtest-mqtt [OPTION...]

Performs a speed test on the configured time schedule and publish the results 
via mqtt.

 General Configs:
  -d, --delay INT            Number of Minutes between two speed tests (Default: 10) 
                             currently not fixed time because time of the speedtest 
                             and publishing add to the DELAY

 Processing options:
  -c, --mqtt-config FILE     Uses the given CONFIG for the mqtt setup.

 Other options:
  -h, --help                 Displays this help"

}

###############################################################################
# parse command line arguments
# prints out all errors but does not exit to collect all errors
###############################################################################

while [[ $# -gt 0 ]]
do
    case "$1" in
    -d | --delay)
        shift

        if [[ $# -lt 1 ]]
        then
            echo "INFO: Missing parameter for delay using default: ${DELAY} s" 1>&2
        else
            echo "Delay set to ${#}"
            DELAY=$#
        fi
        ;;
    -c | --mqtt-config)
        shift
        if [[ $# -lt 1 ]]
        then
            echo "ERROR: Missing parameter for MQTT config" 1>&2
        else
            echo "MQTT config ${#}"
            MQTT_CONFIG=$#
        fi
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo "ERROR: Unknown option: $1" 1>&2
        ;;
    esac

    shift
done


###############################################################################
# config mqtt
###############################################################################

echo "Run mqtt configuration"

###############################################################################
# display infos 
###############################################################################

echo -e "\
Delay:           ${DELAY}

MQTT config:     ${MQTT_CONFIG}
"

###############################################################################
# finish setup activating speedtest
###############################################################################

DELAY=$(( $DELAY*60 ))
echo $DELAY

while true 
do 
    #perform speedtest
    #speedtest --progress=yes -A -f json
    speedtest --accept-license --accept-gdpr -A -f json >> speedtest.json

    #cat speedtest.json

    #publish via mqtt
    
    JITTER=$(jq .ping.jitter speedtest.json)    
    LATENCY=$(jq .ping.latency speedtest.json)    
    LOW=$(jq .ping.low speedtest.json)    
    HIGH=$(jq .ping.high speedtest.json)

    echo "$JITTER $LATENCY $LOW $HIGH"

    mosquitto_pub -h $MQTT_DNS -m "$JITTER" -t speedtest/ping/jitter 
    sleep 1
    mosquitto_pub -h $MQTT_DNS -m "$LATENCY" -t speedtest/ping/latency  
    sleep 1
    mosquitto_pub -h $MQTT_DNS -m "$LOW" -t speedtest/ping/low 
    sleep 1
    mosquitto_pub -h $MQTT_DNS -m "$HIGH" -t speedtest/ping/high 


    sleep ${DELAY}

done
