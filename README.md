# Update-RelayRocketLECert
Automatically handles the copying of a renewed Let's Encrypt SSL certificate to the location that Relay Rocket needs

## Certbot Installation and Initial Execution
Relay Rocket uses Ubuntu 18.04LTS and NGINX.  That version of Ubuntu already comes with SNAP installed (https://snapcraft.io/docs/installing-snapd).  The commands below are summarized from https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
```bash
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly 
```
If for some reason you get an error when issuing the snap command, you may need to manually install snapd.
```bash
sudo apt-get update
sudo apt install snapd
```

The very first time you execute the certbot command you will be prompted to go through the initial setup.  You will be asked a few questions.  Your output will look similar to the following:
```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log

How would you like to authenticate with the ACME CA?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: Spin up a temporary webserver (standalone)
2: Place files in webroot directory (webroot)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 1
Plugins selected: Authenticator standalone, Installer None
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): email@school.org

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

## Primary Server Script Installation
Each of the following sections list instructions to follow in order to complete the installation.  An automatation script may be developed in the future that will perform these tasks upon execution, but that is not included at this time.

### Create Directory
You will need to create a folder inside the /opt path
```bash
sudo mkdir /opt/scripts
```

### File Locations
The following files will need to be created.  This can be done with a file transfer or creating the file directly on the server and pasting the file contents into the file. 
* [certbot2lightspeed.bash](https://github.com/northeastnebraskanetworkconsortium/Update-RelayRocketLECert/blob/main/PrimaryRocket/certbot2lightspeed.bash) - /opt/scripts/
* [.environmentFile](https://github.com/northeastnebraskanetworkconsortium/Update-RelayRocketLECert/blob/main/PrimaryRocket/.environmentFile) - /opt/scripts/
* [rocket-letsencrypt.service](https://github.com/northeastnebraskanetworkconsortium/Update-RelayRocketLECert/blob/main/PrimaryRocket/rocket-letsencrypt.service) - /etc/systemd/system/
* [rocket-letsencrypt.timer](https://github.com/northeastnebraskanetworkconsortium/Update-RelayRocketLECert/blob/main/PrimaryRocket/rocket-letsencrypt.timer) - /etc/systemd/system/

### Make Script Executable
The certbot2lightspeed.bash file must be executable for this process to work.  Regardless how you got that file on the system (manual creation or file transfer), it's recommended to verify if the file is executable or not.  Run the following command
```bash
ls /opt/scripts -al
```
You will get an output similar to
```bash
drwxr-xr-x 2 root root 4096 Mar 19 11:31 .
drwxr-xr-x 3 root root 4096 Mar 19 11:27 ..
-rw-r--r-- 1 root root 1043 Mar 19 11:30 certbot2lightspeed.bash
-rw-r--r-- 1 root root  584 Mar 19 11:31 .environmentFile
```
The permissions for certbot2lightspeed.bash need to be "-rwxr-xr-x".  To change update to those permissions, execute the following command
```bash
 sudo chmod 755 /opt/scripts/certbot2lightspeed.bash
 ```
 
### File Modification
The only file that requires any customization is the .environmentFile, located in /opt/scripts/.  The first argument of this file must contain the FQDN of the SSL certificate that Let's Encrypt is generating for the relayrocket.  
The only other modification that is necessary is if there are multiple Relay Rocket servers in a farm that share the certificate.  Then the certificate must be copied to the other server.  The second and third arguments must be populated to include the appropriate values.

### Enable and Start Services
Once the files have been placed in the correct folders and the .environmentFile has been modified, the services need to be enabled.
```bash
systemctl enable rocket-letsencrypt.service
systemctl enable rocket-letsencrypt.timer
```
The service successfully runs when there is no output that follows the running of that command, if running as root.  If running as a non-root user you will be prompted for your user password (commands only work if user is in sudoers file).  
Next, you need to start the timer file.  You do not need to start the .service file as the .timer file will start it at the appropriate time.
```bash
systemctl start rocket-letsencrypt.timer
```
If you would like to manually verify the service is loaded, you may execute the following command:
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
NEXT                         LEFT          LAST                         PASSED       UNIT                         ACTIVATES
Fri 2021-03-19 12:00:57 CDT  22min left    Fri 2021-03-19 11:04:09 CDT  34min ago    anacron.timer                anacron.service
Fri 2021-03-19 13:32:00 CDT  1h 53min left Fri 2021-03-19 10:51:09 CDT  47min ago    snap.certbot.renew.timer     snap.certbot.renew.service
Fri 2021-03-19 14:16:20 CDT  2h 37min left Thu 2021-03-18 14:16:20 CDT  21h ago      systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Fri 2021-03-19 18:06:29 CDT  6h left       Fri 2021-03-19 02:17:09 CDT  9h ago       motd-news.timer              motd-news.service
Fri 2021-03-19 19:28:55 CDT  7h left       Fri 2021-03-19 11:33:39 CDT  5min ago     apt-daily.timer              apt-daily.service
Fri 2021-03-19 23:32:00 CDT  11h left      n/a                          n/a          rocket-letsencrypt.timer     rocket-letsencrypt.service
Sat 2021-03-20 06:42:16 CDT  19h left      Fri 2021-03-19 06:49:26 CDT  4h 49min ago apt-daily-upgrade.timer      apt-daily-upgrade.service
Mon 2021-03-22 00:00:00 CDT  2 days left   Thu 2021-03-18 14:01:26 CDT  21h ago      fstrim.timer                 fstrim.service

8 timers listed.

Pass --all to see loaded but inactive timers, too.
```
In the sample output above, the "11h left" in the 2nd column indicates the timer is started and is counting down until it will run next.  Columns 3 and 4 with values of "n/a" just mean the timer has not yet been run.  Notice you can see both the rocket-letsencrypt.timer and snap.certbot.renew.timer (which the later was setup by the original Certbot installation).

### Manually Test Script
As long as you have completed setup above, you can manually run the script by starting executing the rocket-letsencrypt.service file.
```bash
systemctl start rocket-letsencrypt.service
```
After the .service file has been executed at least once (either manually or by the .timer), one or two small files are generated for the sole purpose of marking the last time the script was ran (/opt/scripts/lastexecuted) and the last time the script copied and renamed the certificate (/opt/scripts/lastcopied).  The contents of the files just show you which user was used to execute the script, which will be root.  It's the date/time stamp of those files that tells you when it was executed last.

## Secondary Server Script Installation (optional)
Each of the following sections list instructions to follow in order to complete the installation for the secondary server.  An automatation script may be developed in the future that will perform these tasks upon execution, but that is not included at this time.

### Multiple Server Prequisites 
In order to seemlessly transfer the files between servers, the sending server must have a public/private key pair generated with the public key copied to the receiving server. The following command elevates the key generation to root, since systemd uses root for the execution of the timer. 
```bash
sudo -H  ssh-keygen -t rsa -b 4096
```
You will be prompted to enter a save location.  The default location of '/root/.ssh/id_rsa' is fine.  Next, you will be prompted to enter a passphrase, but it can be left empty.  Go ahead and leave it empty.

Next, you must copy the public key to the remote server.  Again, the following command elevates to copy of the key from the root user, since systemd uses root for the execution of the timer. 
```bash
# Where <ftpuser> represents the ftp user on the remote server and <10.1.2.3> represents the IP address of the local server
sudo -H ssh-copy-id <ftpuser>@<10.1.2.3>
```
In a multiple server configuration, only one server needs to be configured with Certbot; the other server(s) simply need to receive the generated SSL certificate and have them placed in the correct location.

### The following commands are to be performed on the secondary server
### Create Directory
You will need to create a folder inside the /opt path
```bash
sudo mkdir /opt/scripts
```

### File Locations
The following files will need to be created.  This can be done with a file transfer or creating the file directly on the server and pasting the file contents into the file. 
* [copy-certificates.bash](https://github.com/northeastnebraskanetworkconsortium/Update-RelayRocketLECert/blob/main/SecondaryRocket/copy-certificates.bash) - /opt/scripts/
* [copy-certificates.service](https://github.com/northeastnebraskanetworkconsortium/Update-RelayRocketLECert/blob/main/SecondaryRocket/copy-certificates.service) - /etc/systemd/system/
* [copy-certificates.timer](https://github.com/northeastnebraskanetworkconsortium/Update-RelayRocketLECert/blob/main/SecondaryRocket/copy-certificates.timer) - /etc/systemd/system/

### Make Script Executable
The copy-certificates.bash file must be executable for this process to work.  Regardless how you got that file on the system (manual creation or file transfer), it's recommended to verify if the file is executable or not.  Run the following command
```bash
ls /opt/scripts -al
```
You will get an output similar to
```bash
drwxr-xr-x 2 root root 4096 Mar 19 11:31 .
drwxr-xr-x 3 root root 4096 Mar 19 11:27 ..
-rw-r--r-- 1 root root 1043 Mar 19 11:30 copy-certificates.bash
```
The permissions for copy-certificates.bash need to be "-rwxr-xr-x".  To change update to those permissions, execute the following command
```bash
 sudo chmod 755 /opt/scripts/copy-certificates.bash
 ```

### Enable and Start Services
Once the files have been placed in the correct folders and the .environmentFile has been modified, the services need to be enabled.
```bash
systemctl enable copy-certificates.service
systemctl enable copy-certificates.timer
```
The service successfully runs when there is no output that follows the running of that command, if running as root.  If running as a non-root user you will be prompted for your user password (commands only work if user is in sudoers file).  
Next, you need to start the timer file.  You do not need to start the .service file as the .timer file will start it at the appropriate time.
```bash
systemctl start copy-certificates.timer
```
If you would like to manually verify the service is loaded, you may execute the following command:
```bash
systemctl status copy-certificates.timer
```
You will get an output similar to
```bash
● copy-certificates.timer - Timer copies certs to rocket directory and to other server
   Loaded: loaded (/etc/systemd/system/copy-certificates.timer; disabled; vendor preset: enabled)
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
NEXT                         LEFT          LAST                         PASSED       UNIT                         ACTIVATES
Fri 2021-03-19 12:00:57 CDT  22min left    Fri 2021-03-19 11:04:09 CDT  34min ago    anacron.timer                anacron.service
Fri 2021-03-19 13:32:00 CDT  1h 53min left Fri 2021-03-19 10:51:09 CDT  47min ago    snap.certbot.renew.timer     snap.certbot.renew.service
Fri 2021-03-19 14:16:20 CDT  2h 37min left Thu 2021-03-18 14:16:20 CDT  21h ago      systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Fri 2021-03-19 18:06:29 CDT  6h left       Fri 2021-03-19 02:17:09 CDT  9h ago       motd-news.timer              motd-news.service
Fri 2021-03-19 19:28:55 CDT  7h left       Fri 2021-03-19 11:33:39 CDT  5min ago     apt-daily.timer              apt-daily.service
Fri 2021-03-19 23:32:00 CDT  11h left      n/a                          n/a          copy-certificates.timer      copy-certificates.service
Sat 2021-03-20 06:42:16 CDT  19h left      Fri 2021-03-19 06:49:26 CDT  4h 49min ago apt-daily-upgrade.timer      apt-daily-upgrade.service
Mon 2021-03-22 00:00:00 CDT  2 days left   Thu 2021-03-18 14:01:26 CDT  21h ago      fstrim.timer                 fstrim.service

8 timers listed.

Pass --all to see loaded but inactive timers, too.
```
In the sample output above, the "11h left" in the 2nd column indicates the timer is started and is counting down until it will run next.  Columns 3 and 4 with values of "n/a" just mean the timer has not yet been run.  Notice you can see both the rocket-letsencrypt.timer and snap.certbot.renew.timer (which the later was setup by the original Certbot installation).

### Manually Test Script
As long as you have completed setup above, you can manually run the script by starting executing the copy-certificates.service file.
```bash
systemctl start copy-certificates.service
```
After the .service file has been executed at least once (either manually or by the .timer), one small file is generated for the sole purpose of marking the last time the script was ran (/opt/scripts/lastexecuted).  The contents of the files just show you which user was used to execute the script, which will be root.  It's the date/time stamp of that file that tells you when it was executed last.
