#!/bin/sh
# by Andy Boell
# March 19, 2021

# Change directory
cd /usr/local/rocket/letsencrypt/

current=`date +%s`
modified=`stat -c "%Y" portal.key`
if [ $(($current-$modified)) -lt 86400 ]; then

  # Change permissions on key
  chmod 640 portal.key

  # Change permissions on cert
  chmod 644 portal.crt

  # Copy certificates to destination
  cp portal.* ../etc

  # Restart the Nginx Service
  systemctl restart nginx.service
fi