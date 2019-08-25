# Simple Letsencrypt Wildcard Certificates with Bind9 authentication

I needed a super simple way to get DNS challenge auth with bind, didn't want to mess with rndc or nsupdate
for that reason I wrote in one night this easy single script.

# Uses
If you want to create certificates based on dns-challenge with letsencrypt, this script will show you the basics and you already
have some super simple hooks system to do your own before and after operations.

# Configuration
Most of it you may find in utils.sh, the rest in domlist.sh.

# Hooks
Check hooks.sh, there you'll find the before, after and another one we use.

This scipt in our server is set to run by a cronjob weekly, so far we've found no issues, and has worked like a charm.

# Reporting bugs

I accept any input, and there's no license to it, do what ever you want. I might take a bit to reply but that's because I only mirror projects with Github, I use my own Gitlab server at: https://git.derekdemuro.com

Enjoy!
