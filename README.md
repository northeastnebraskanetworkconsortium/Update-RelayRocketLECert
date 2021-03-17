# Update-RelayRocketLECert
Automatically handles the copying of a renewed Let's Encrypt SSL certificate to the location that Relay Rocket needs

## Certbot Installation and Initial Execution
Relay Rocket uses Ubuntu 18.04LTS and NGINX.  That version of Ubuntu already comes with SNAP installed (https://snapcraft.io/docs/installing-snapd).  The commands below are summarized from https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
```bash
sudo snap install core; sudo snap refresh core
sudo apt-get remove remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly --nginx
```
## File Locations
certbot2lightspeed.bash - /opt/scripts/
.environmentFile - /opt/scripts/
rocket-letsencrypt.service - /etc/systemd/system/
rocket-letsencrypt.timer - /etc/systemd/system/

## File Modification
The only file that requires any customization is the .environmentFile, located in /opt/scripts/.  The first argument of this file must contain the FQDN of the SSL certificate that Let's Encrypt is generating for the relayrocket.  
The only other modification that is necessary is if there are multiple Relay Rocket servers in a farm that share the certificate.  Then the certificate must be copied to the other server.  The second and third arguments must be populated to include the appropriate values.

## Multiple Server Prequisites
In order to seemlessly transfer the files between servers, the sending server must have a public/private key pair generated with the public key copied to the receiving server. The following command elevates the key generation to root, since systemd uses root for the execution of the timer. 
```bash
sudo -H  ssh-keygen -t rsa -b 4096
```
Next, you must copy the public key to the remote server.  Again, the following command elevates to copy of the key from the root user, since systemd uses root for the execution of the timer. 
```bash
# Where <ftpuser> represents the ftp user on the remote server and <10.1.2.3> represents the IP address of the local server
sudo -H ssh-copy-id <ftpuser>@<10.1.2.3>
```
