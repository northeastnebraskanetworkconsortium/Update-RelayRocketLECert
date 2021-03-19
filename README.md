# Update-RelayRocketLECert
Automatically handles the copying of a renewed Let's Encrypt SSL certificate to the location that Relay Rocket needs

## Certbot Installation and Initial Execution
Relay Rocket uses Ubuntu 18.04LTS and NGINX.  That version of Ubuntu already comes with SNAP installed (https://snapcraft.io/docs/installing-snapd).  The commands below are summarized from https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
```bash
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly --nginx
```
The very first time you execute the certbot command you will be prompted to go through the initial setup.  You will be asked a few questions.  Your output will look similar to the following:
```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): user@school.org

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: N
Account registered.
No names were found in your configuration files. Please enter in your domain
name(s) (comma and/or space separated)  (Enter 'c' to cancel): test.school.org
Requesting a certificate for test.nnnc.org
Performing the following challenges:
http-01 challenge for test.school.org
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/test.school.org/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/test.school.org/privkey.pem
   Your certificate will expire on 2021-06-16. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

## Update Script Installation
Each of the following sections list instructions to follow in order to complete the installation.  An automatation scrip may be developed in the future that will perform these tasks upon execution, but that is not included at this time.

### Create Directory
You will need to create a folder inside the /opt path
```bash
sudo mkdir /opt/scripts
```

### File Locations
The following files will need to be created.  This can be done with a file transfer or creating the file directly on the server and pasting the file contents into the file. 
* certbot2lightspeed.bash - /opt/scripts/
* .environmentFile - /opt/scripts/
* rocket-letsencrypt.service - /etc/systemd/system/
* rocket-letsencrypt.timer - /etc/systemd/system/

### File Modification
The only file that requires any customization is the .environmentFile, located in /opt/scripts/.  The first argument of this file must contain the FQDN of the SSL certificate that Let's Encrypt is generating for the relayrocket.  
The only other modification that is necessary is if there are multiple Relay Rocket servers in a farm that share the certificate.  Then the certificate must be copied to the other server.  The second and third arguments must be populated to include the appropriate values.

### Start Services
Once the files have been placed in the correct folders and the .environmentFile has been modified, the services need to be enabled.
```bash
systemctl enable rocket-letsencrypt.service
systemctl enable rocket-letsencrypt.timer
```
The service successfully runs when there is no output that follows the running of that command.  If you would like to manually verify the service is loaded, you may execute the following command:
```bash
systemctl status rocket-letsencrypt.service
```
You will get an output similar to
```bash
● rocket-letsencrypt.service - Moves letsencrypt files to rocket folder
   Loaded: loaded (/etc/systemd/system/rocket-letsencrypt.service; enabled; vendor preset: enabled)
   Active: inactive (dead) since Thu 2021-03-18 11:17:08 CDT; 14min ago
  Process: 19803 ExecStart=/opt/scripts/certbot2lightspeed.bash $ARG1 $ARG2 $ARG3 (code=exited, status=0/SUCCESS)
 Main PID: 19803 (code=exited, status=0/SUCCESS)

Mar 18 11:17:08 relayrocket1 systemd[1]: Starting Moves letsencrypt files to rocket folder...
Mar 18 11:17:08 relayrocket1 certbot2lightspeed.bash[19803]: pwd
Mar 18 11:17:08 relayrocket1 certbot2lightspeed.bash[19803]: 1615413375
Mar 18 11:17:08 relayrocket1 systemd[1]: Started Moves letsencrypt files to rocket folder.
```
and
```bash
systemctl status rocket-letsencrypt.timer
```
You will get an output similar to
```bash
● rocket-letsencrypt.timer - Timer copies certs to rocket directory and to other server
   Loaded: loaded (/etc/systemd/system/rocket-letsencrypt.timer; disabled; vendor preset: enabled)
   Active: active (waiting) since Tue 2021-03-16 11:08:21 CDT; 2 days ago
  Trigger: Thu 2021-03-18 23:32:00 CDT; 11h left

Mar 16 11:08:21 relayrocket1 systemd[1]: Started Timer copies certs to rocket directory and to other server.
```

To check if the timers are enabled at any given point, you can execute this command
```bash
systemctl list-timers
```
You will get an output similar to
```bash
NEXT                         LEFT        LAST                         PASSED       UNIT                         ACTIVATES
Thu 2021-03-18 17:41:24 CDT  6h left     Wed 2021-03-17 17:41:24 CDT  17h ago      systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Thu 2021-03-18 22:19:08 CDT  10h left    Thu 2021-03-18 10:39:19 CDT  54min ago    apt-daily.timer              apt-daily.service
Thu 2021-03-18 23:22:27 CDT  11h left    Thu 2021-03-18 09:08:19 CDT  2h 25min ago motd-news.timer              motd-news.service
Thu 2021-03-18 23:28:00 CDT  11h left    Thu 2021-03-18 08:02:26 CDT  3h 31min ago snap.certbot.renew.timer     snap.certbot.renew.service
Thu 2021-03-18 23:32:00 CDT  11h left    Thu 2021-03-18 08:07:26 CDT  3h 26min ago rocket-letsencrypt.timer     rocket-letsencrypt.service
Fri 2021-03-19 06:23:01 CDT  18h left    Thu 2021-03-18 06:39:37 CDT  4h 54min ago apt-daily-upgrade.timer      apt-daily-upgrade.service
Mon 2021-03-22 00:00:00 CDT  3 days left Mon 2021-03-15 00:00:37 CDT  3 days ago   fstrim.timer                 fstrim.service

7 timers listed.
Pass --all to see loaded but inactive timers, too.
```
Notice you can see both the rocket-letsencrypt.timer and snap.certbot.renew.timer (which the later was setup by the original Certbot installation).

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
