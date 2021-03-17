# Update-RelayRocketLECert
Automatically handles the copying of a renewed Let's Encrypt SSL certificate to the location that Relay Rocket needs

## File Locations
certbot2lightspeed.bash - /opt/scripts/
.environmentFile - /opt/scripts/
rocket-letsencrypt.service - /etc/systemd/system/
rocket-letsencrypt.timer - /etc/systemd/system/

## File Modification
The only file that requires any customization is the .environmentFile, located in /opt/scripts/.  The first argument of this file must contain the FQDN of the SSL certificate that Let's Encrypt is generating for the relayrocket.  
The only other modification that is necessary is if there are multiple Relay Rocket servers in a farm that share the certificate.  Then the certificate must be copied to the other server.  The second and third arguments must be populated to include the appropriate values.

## Multiple Server Prequisites
In order to seemlessly transfer the files between servers, the sending server must have a public/private key pair generated with the public key copied to the receiving server.  
Before issuing the following command, be sure you're logged into the account
```bash
ssh-keygen -t rsa -b 4096
```
