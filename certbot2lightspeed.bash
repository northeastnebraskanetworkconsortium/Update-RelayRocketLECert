#!/bin/sh
# Created by Andy Boell, NNNC
# March 17, 2021
# 
# Required parameter(s) in /opt/scripts/.environmentFile to be populated

# Flag to indicate last time script was ran
echo $(id) > /opt/scripts/lastexecuted

# Change directory
cd /etc/letsencrypt/live/$1

# Test if certificate has recently been updated (less than 1 day)
current=`date +%s`
modified=`stat -c "%Y" privkey.pem`
if [ $(($current-$modified)) -lt 86400 ]; then

  # Flag to indicate last time cert was copied
  echo $(id) > /opt/scripts/lastcopied

  # Extract key from new certificate
  openssl pkey -in privkey.pem -out portal.key

  # Extract convert cert from pem to crt
  cp cert.pem portal.crt

  # Copy cert and key to relayrocket folder
  cp portal.* /usr/local/rocket/etc

  # Change permissions on key
  chmod 640 portal.key

  # Change permissions on cert
  chmod 644 portal.crt

  # Restart the Nginx Service
  systemctl restart nginx.service

# Copy files to next relay rocket only if the ftp user is not null
  if [$2 != 'NULL']; then
    scp /usr/local/rocket/etc/portal.* $2@$3:/usr/local/rocket/letsencrypt/
  fi
fi
