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
## Update Script Installation
Each of the following sections list instructions to follow in order to complete the installation.  An automatation scrip may be developed in the future that will perform these tasks upon execution, but that is not included at this time.

### File Locations
* certbot2lightspeed.bash - /opt/scripts/
* .environmentFile - /opt/scripts/
* rocket-letsencrypt.service - /etc/systemd/system/
* rocket-letsencrypt.timer - /etc/systemd/system/

### File Modification
The only file that requires any customization is the .environmentFile, located in /opt/scripts/.  The first argument of this file must contain the FQDN of the SSL certificate that Let's Encrypt is generating for the relayrocket.  
The only other modification that is necessary is if there are multiple Relay Rocket servers in a farm that share the certificate.  Then the certificate must be copied to the other server.  The second and third arguments must be populated to include the appropriate values.

### Start Timer Service
Once the files have been placed in the correct folders and the .environmentFile has been modified, the service timer needs to be started.
```bash
systemctl enable rocket-letsencrypt.service
systemctl start rocket-letsencrypt.service
```
The service successfully runs when there is no output that follows the running of that command.  If you would like to manually verify the service is started, you may execute the following command:
```bash
systemctl status rocket-letsencrypt.service
```


### Multiple Server Prequisites (optional)
In order to seemlessly transfer the files between servers, the sending server must have a public/private key pair generated with the public key copied to the receiving server. The following command elevates the key generation to root, since systemd uses root for the execution of the timer. 
```bash
sudo -H  ssh-keygen -t rsa -b 4096
```
Next, you must copy the public key to the remote server.  Again, the following command elevates to copy of the key from the root user, since systemd uses root for the execution of the timer. 
```bash
# Where <ftpuser> represents the ftp user on the remote server and <10.1.2.3> represents the IP address of the local server
sudo -H ssh-copy-id <ftpuser>@<10.1.2.3>
```
In a multiple server configuration, only one server needs to be configured with Certbot; the other server(s) simply need to receive the generated SSL certificate and have them placed in the correct location.
