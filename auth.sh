#!/bin/bash
SLEEP=10
source utils.sh

echo $DNS_P >> $LOG

# Make sure the zone doesn't have a challenge!
remove_from_zone $CERTBOT_DOMAIN

# Lets replace the certbot stuff
echo "$CERTBOT_DOMAIN $CERTBOT_VALIDATION" >> $LOG
add_to_zone $CERTBOT_DOMAIN $CERTBOT_VALIDATION

# Let's get that domain in sync, hopefully everything will blow up...
reload_bind

# Sleep to make sure the change has time to propagate over to DNS
sleep_max=1200
while [ TRUE ]; do
    dns_check_txt_challenge $CERTBOT_VALIDATION
    if [ $RES -eq 0 ] || [ $sleep_max -le 0 ]; then
        if [ $RES -eq 0 ]; then
            # We're in sync yo...
            copy_certs
            echo "We're good, certs copied over" >> $LOG
            exit 0
        else
            # Exceeded max sleep time yo!
            echo "Max time expired, sorry!" >> $LOG
            exit 1
        fi
    fi
    sleep_max=$(($sleep_max - $SLEEP))
    echo $sleep_max >> $LOG
    sleep $SLEEP
done