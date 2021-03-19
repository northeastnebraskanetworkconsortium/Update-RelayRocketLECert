#!/bin/sh
# by Andy Boell
# March 19, 2021

# Change directory
cd /usr/local/rocket/letsencrypt/

# Change permissions on key
chmod 640 portal.key

# Change permissions on cert
chmod 644 portal.crt

# Copy certificates to destination
mv portal.* ../etc

# Restart the Nginx Service
systemctl restart nginx.service