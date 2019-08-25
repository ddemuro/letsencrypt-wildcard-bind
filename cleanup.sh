#!/bin/bash
source utils.sh

# Remove challenge
remove_from_zone $CERTBOT_DOMAIN

# Reload bind
reload_bind