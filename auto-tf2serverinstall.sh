#!/bin/bash
#Purpose - This is a script to automate the process of installing a tf2server stack on a clean Debian or Ubuntu server instance. The script needs to be ran as root to function properly. Please auit the code below before running in your envoirment.

# Variables used in script.
export METAMODURL='https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git961-linux.tar.gz'
export METAMODFILENAME='mmsource-1.10.7-git961-linux.tar.gz'
export SOURCEMODURL='https://sm.alliedmods.net/smdrop/1.8/sourcemod-1.8.0-git6041-linux.tar.gz'
export SOURCEMODFILENAME='sourcemod-1.8.0-git6041-linux.tar.gz'
export STEAMID='PUT-STEAM-ID-HERE'
export STEAMUSERNAME='PUT-STEAM-USERNAME-HERE'
export DEFAULTMAP='pl_upward'
export PLAYERS='24'

# Check if running with sudo/root privilages
if [ "$EUID" -ne 0 ]
then
  echo "Run as root or use sudo."
  exit 1
fi

# Install sudo incase its not installed.
apt-get -y install sudo chpasswd

# Get sudo rights just in case
sudo -v

# Update the server
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo apt-get autoclean

# Install dependices for the tf2server instance
sudo dpkg --add-architecture i386; sudo apt-get update; sudo apt-get install mailutils curl wget file bzip2 gzip unzip bsdmainutils python util-linux ca-certificates binutils bc tmux lib32gcc1 libstdc++6 libstdc++6:i386 libcurl4-gnutls-dev:i386 libtcmalloc-minimal4:i386 vim -y

# Add user account
useradd -m -s /bin/bash tf2server
echo password1 | chpasswd tf2server

# Get the framework script and install the server.
su - tf2server -c 'wget -N --no-check-certificate https://gameservermanagers.com/dl/linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh tf2server'
su - tf2server -c '/home/tf2server/tf2server auto-install'
su - tf2server -c "echo "defaultmap=\"$DEFAULTMAP\"" > /home/tf2server/lgsm/config-lgsm/tf2server/tf2server.cfg"
su - tf2server -c "echo "maxplayers=\"$PLAYERS\"" >> /home/tf2server/lgsm/config-lgsm/tf2server/tf2server.cfg"
su - tf2server -c "echo 'updateonstart="on"' >> /home/tf2server/lgsm/config-lgsm/tf2server/tf2server.cfg"
# su - tf2server -c 'vim /home/tf2server/lgsm/config-lgsm/tf2server/tf2server.cfg'
su - tf2server -c '/home/tf2server/tf2server start'


# Setup web server
sudo apt-get install -y apache2
mkdir -p /var/www/html/fastdl/tf2/
cd /var/www/html/fastdl/tf2/
ln -s /home/tf2server/serverfiles/tf/maps maps
sudo systemctl start apache2.service
sudo systemctl enable apache2.service
mv /var/www/html/index.html /var/www/html/index.html.bak

# Setup metamod and sourcemod
cat << EOF >> /home/tf2server/source-metamodinstall.sh
cd /home/tf2server/serverfiles/tf
wget $METAMODURL
tar -xf $METAMODFILENAME
rm $METAMODFILENAME

wget $SOURCEMODURL
tar -xf $SOURCEMODFILENAME
rm $SOURCEMODFILENAME
EOF

chown tf2server:tf2server /home/tf2server/source-metamodinstall.sh
chmod +x /home/tf2server/source-metamodinstall.sh
su - tf2server -c '/home/tf2server/source-metamodinstall.sh'
su - tf2server -c 'rm /home/tf2server/source-metamodinstall.sh'

# Setup Steam id's for admin
cat << EOF >> /home/tf2server/steamid.sh

cat <<EOL >> /home/tf2server/serverfiles/tf/addons/sourcemod/configs/admins_simple.ini
"$STEAMID" "99:z" //$STEAMUSERNAME
EOL

EOF

chmod +x /home/tf2server/steamid.sh
su - tf2server -c '/home/tf2server/steamid.sh'
su - tf2server -c 'rm -f /home/tf2server/steamid.sh'

# Restart the server to load sourcemod install.
su - tf2server -c '/home/tf2server/tf2server restart'

# Add cronjobs
echo "@reboot         tf2server /home/tf2server/tf2server start" >> /etc/crontab
echo "0 0     * * *   tf2server /home/tf2server/tf2server restart" >> /etc/crontab

# Set a restart of the server for midnight incase it is not done manually.
sudo shutdown -r -t 0:00
