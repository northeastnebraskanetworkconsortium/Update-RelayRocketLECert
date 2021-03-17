#!/bin/sh
# Created by Andy Boell, NNNC
# March 16, 2021
# Implementation specific variables REQUIRED:
#  - path to Let's Encrypt certificate <certificate FQDN>
# Implementation specific varialbes OPTIONAL - only required if multiple Relay Rockets are installed on a farm
#  - account name of FTP user <ftp user>
#  - IP address of Relay Rocket on farm to copy certificate to <rocket IP>

# Change directory
cd /etc/letsencrypt/live/<certificate FQDN>

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

# Copy files to next relay rocket
scp /usr/local/rocket/etc/portal.* <ftp user>@<rocket IP>:/usr/local/rocket/letsencrypt/

