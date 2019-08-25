#!/bin/bash
[[ $CHECK_UTILS_IMPORTED != 1 && -f utils.sh ]] && source utils.sh

# Just to check if hooks sources was alrady imported.
CHECK_HOOKS_IMPORTED=1

readonly CMDSPOOLER='/tmp/commandSpooler.run'

# Other aux functions (Use functions if you want to call them in a different order)

# Copy certs to shared location / 
function copy_certs(){
    # Gen domains
    for line in "${DNS_TO_VALIDATE[@]}"; do
        line=`echo $line | sed 's/\*\.//g'`
        LOCATION="/opt/scripts/domain-certs/$line"
        mkdir -p $LOCATION
        cp /etc/letsencrypt/live/$line/fullchain.pem $LOCATION/ssl.cert
        cp /etc/letsencrypt/live/$line/privkey.pem $LOCATION/ssl.key
        cp $LOCATION/ssl.key /home/$line/ssl.cert
        cp $LOCATION/privkey.pem /home/$line/ssl.key
    done
    echo "Done copying to folder"
}

# Before certbot
function before_hook(){
    echo "Running command before we run certbot auth."
}

# After certbot
# Create taskSpooler queue to reload apache / nginx
function after_hook(){
    echo "Running command after we run certbot auth."
    # Reload apache in SEC01
    CMDVAR=""
    CMDVAR2=""
    for sym in "${SYMLINKS[@]}"; do
        CMDVAR="$CMDVAR ln -sn $sym\n"
    done
    # Gen domains
    for line in "${DNS_TO_VALIDATE[@]}"; do
        line=`echo $line | sed 's/\*\.//g'`
        CMDVAR2="$CMDVAR2 cp /opt/scripts/domain-certs/$line/ssl.* /home/$line/\n"
    done

    echo "Telling servers to check symlinks with: $CMDVAR and $CMDVAR2" >> $LOG
    ssh root@lsyncd-vmin.nj.takelan.com "echo \"$CMDVAR\n$CMDVAR2\nservice apache2 reload\nservice postfix reload\nservice dovecot reload\n\" >> $CMDSPOOLER"
    ssh root@10.3.0.49 "echo \"service nginx reload\" >> $CMDSPOOLER"
    echo "service apache2 reload\nservice postfix reload\nservice dovecot reload" >> $CMDSPOOLER
}