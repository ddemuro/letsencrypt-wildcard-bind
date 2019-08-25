#!/bin/bash
[[ $CHECK_DOMLIST_IMPORTED != 1 && -f domlist.sh ]] && source domlist.sh

# Just to make sure we import utils once
readonly CHECK_UTILS_IMPORTED=1

readonly DEBUG=0
readonly LOG='/var/log/letsencrypt-d.log'
readonly AUTHHOOKPATH='/opt/letsencrypt/auth.sh'
readonly CLEANUPHOOKPATH='/opt/letsencrypt/cleanup.sh'
# Max lines in log
readonly MAXLINES=30000

# Reload bind
function reload_bind(){
    service bind9 reload
}

# Removes txt challenge to domain
function remove_from_zone(){
    FILENAME="/var/lib/bind/$1.hosts"
    FILENAME=${FILENAME/\.\./\.}
    echo "Removing TXT record!" >> $LOG
    sed -i "s/^_acme-challenge.$1.*$//g" $FILENAME
}

# Test domains with dig for all Auth DNS Servers
function dns_check_txt_challenge(){
    for server in "${DNS_P[@]}" ; do
        echo $server >> $LOG
        VALUE=`dig TXT +noadditional +noquestion +nocomments +nocmd +nostats +short "_acme-challenge.$CERTBOT_DOMAIN." @$server`
        echo $VALUE >> $LOG
        if [ "$VALUE" != "\"$1\"" ] ; then
            echo "Didn't validate, $VALUE is not equal to $1" >> $LOG
            RES=-1
            return 1
        fi
        RES=0
    done
    return 0
}

# Check symlinks
function create_symlinks(){
    for sym in "${SYMLINKS[@]}"; do
        echo "Checking symlink for: $sym" >> $LOG
        p1=`echo $sym | cut -d' ' -f1`
        p2=`echo $sym | cut -d' ' -f2`
        echo "ln -s $p1 $p2" >> $LOG
        ln -sn "$p1" "$p2"
    done
}

# Adds txt challenge to domain
function add_to_zone(){
    FILENAME="/var/lib/bind/$1.hosts"
    FILENAME=${FILENAME/\.\./\.}
    TXT="_acme-challenge.$1.    5    IN    TXT    \"$2\""
    echo "$FILENAME $1 $TXT" >> $LOG
    if grep -Fqx "_acme-challenge.$1" $FILENAME; then
        sed -i "s/^_acme-challenge.$1.*$/$TXT/g" $FILENAME
    else
        echo "$TXT" >> $FILENAME
    fi
}

# Rsync changes to server
function rsync_to_servers(){
    for line in "${RSYNC_SERVERS[@]}"; do
        rsync -avzPkLl /opt/scripts/domain-certs/ root@line:/opt/scripts/domain-certs/
    done
}

###Function to clear the log
function clearLog() {
  echo 'Log cleared' > $LOG
  echo 'Script will run ' $1 ' times then will clear itself'>> $LOG
}

## We check if the logfile exists, otherwise we create it
if [ ! -f $LOG ]; then
	touch $LOG
fi

##CLEAR THE LOG IF LINES > MAXLINES
loglines=`wc -l < $LOG`
if [ $loglines -eq $MAXLINES ]; then
	clearlog
fi
