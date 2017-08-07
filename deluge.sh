#!/bin/bash
clear
echo "+--------------------------------------------------------------------+"
echo "| This script will install Deluge on your Ubuntu Server              |"
echo "|                                                                    |"
echo "| ####################### e-sean - 2017 #######################      |"
echo "+--------------------------------------------------------------------+"
any_key "Press any key to start the script..."
clear

#sudo apt-get install python-software-properties -y 
echo "Adding the Deluge repository"
#yes "" | sudo add-apt-repository ppa:deluge-team/ppa

echo "Updating system..."
#sudo apt update -y

#sudo apt upgrade -y

echo "Installing Deluge..."
#sudo apt install deluged deluge-web -y 
###########DELUGE USER ##############

echo "Adding Deluge user..."
sudo adduser --system  --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge
echo "Adding current user to Deluge group..."
sudo adduser "$(whoami)" deluge
########### DAEMON SERVICE ##########

sudo rm deluged.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluged.service
echo "Creating systemd service for Deluge Daemon..."
sudo cp deluged.service /etc/systemd/system/

echo "Starting Deluge Daemon"
sudo systemctl daemon-reload
sudo systemctl start deluged
sudo systemctl enable deluged.service


########### WEB-UI SERVICE ##########


sudo rm deluge-web.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluge-web.service
echo "Creating systemd service for Deluge Web-UI..."
sudo cp deluge-web.service /etc/systemd/system/

echo "Starting Deluge Web-UI"
sudo systemctl daemon-reload
sudo systemctl start deluge-web
sudo systemctl enable deluge-web.service

############# OPEN PORT###############

echo "Opening port 8112 for web access"
sudo iptables -I INPUT -p tcp --dport 8112 -j ACCEPT

#####kill deluge #########
killall deluged 
killall deluge-web

########User and password#############
read -p 'Enter a username for Deluge remote connection: ' usr
read -sp 'Enter a new password: ' pass
echo "$usr:$pass:10" >> /var/lib/deluge/.config/deluge/auth

########Allow remote ############
sudo sed -i 's/"allow_remote": false/"allow_remote": true/g' /var/lib/deluge/.config/deluge/core.conf

sudo sed -i 's/"default_daemon": "",/"default_daemon": "127.0.0.1:58846",/g' /var/lib/deluge/.config/deluge/web.conf

sudo systemctl start deluged
sudo systemctl start deluge-web
echo "Installation is done!"
echo "You can access deluge @ http://ip-address:8112"
