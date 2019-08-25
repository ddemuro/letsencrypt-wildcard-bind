#!/bin/bash
[[ $CHECK_UTILS_IMPORTED != 1 && -f utils.sh ]] && source utils.sh
[[ $CHECK_HOOKS_IMPORTED != 1 && -f hooks.sh ]] && source hooks.sh

apt-get install -qq python-certbot-apache -t stretch-backports

# Test domains with dig for all Auth DNS Servers
function dns_check_txt_challenge(){
    for server in "${DNS_TO_VALIDATE[@]}"; do
        echo "Running certbot for $server" >> $LOG
        if [ $DEBUG -eq 1 ]; then
            certbot certonly --manual --dry-run -n --agree-tos --manual-public-ip-logging-ok --preferred-challenges=dns --manual-auth-hook $AUTHHOOKPATH --manual-cleanup-hook $CLEANUPHOOKPATH -d "$server" >> $LOG
        else
            certbot certonly --manual --preferred-challenges=dns -n --manual-public-ip-logging-ok --agree-tos --manual-auth-hook $AUTHHOOKPATH --manual-cleanup-hook $CLEANUPHOOKPATH -d "$server" >> $LOG
        fi
    done
}

# Preparations before certbot!
before_hook

# Run certbot!
dns_check_txt_challenge

# Check symlinks
create_symlinks

# Copy certificates to shared location
copy_certs

# Send files to the servers
rsync_to_servers

# Preparations to run after certbot
after_hook

echo "Done. $DEBUG" >> $LOG
