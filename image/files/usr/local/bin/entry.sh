#!/bin/bash

###############################################################################
# declare constants for easier later changes
###############################################################################

readonly MQTT_DNS="NAS-GW4.fritz.box"
readonly MQTT_PORT=1883


###############################################################################
# setup defaults for options
###############################################################################

DELAY=10
MQTT_CONFIG='/usr/local/bin/speedtest.sh'

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
cat ${MQTT_CONFIG}

###############################################################################
# finish setup activating cron job
###############################################################################
echo "Activating cron job"
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
MINUTES=(${DELAY}%60)
echo ${MINUTES}
HOURS=(${HOURS}/60)
#echo "${MINUTES} ${HOURS} * * * ./usr/local/bin/speedtest.sh" >> mycron
echo "10 * * * * ./usr/local/bin/speedtest.sh" >> mycron
#install new cron file
cat mycron
crontab mycron
rm mycron
tail -f /var/log/syslog | grep CRON

echo "Done"

while true 
    do sleep 100 
done
