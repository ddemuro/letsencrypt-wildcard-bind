#!/bin/bash

# Just to make sure we import the list only once
CHECK_DOMLIST_IMPORTED = 1

# Domains
DNS_TO_VALIDATE=(
    '*.takelan.com'
    '*.derekdemuro.com'
)

# Auth nameservers (That we'll use to make sure our TXT records have propagated)
DNS_P=(
    'ns1.takelan.com'
    'ns2.takelan.com'
    'ns3.takelan.com'
    'ns4.takelan.com'
    'ns5.takelan.com'
)

# Symlinks (To make sure virtualmin domain-host match the domain wild-card)
SYMLINKS=(
    '/home/derekdemuro /home/derekdemuro.com'
    '/home/tkln /home/tkln.dev'
)

# To sync certificates to all the servers
RSYNC_SERVERS=(
    'lsyncd-vmin.tx.takelan.com'
    'lsyncd-vmin.nj.takelan.com'
    'lsyncd-vmin.la.takelan.com'
    'lsyncd-vmin.ks.takelan.com'
)