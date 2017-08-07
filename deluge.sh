#!/bin/bash

source "$(pwd)/spinner.sh"


any_key() {
    local PROMPT="$1"
    read -r -p "$(printf "${Green}${PROMPT}${Color_Off}")" -n1 -s
    echo
}

clear
echo "+----------------------------------------------------------------+"
echo "| This script will install Deluge on your Ubuntu Server          |"
echo "|                                                                |"
echo "| ####################### e-sean - 2017 #######################  |"
echo "+----------------------------------------------------------------+"
any_key "Press any key to start the script..."

#sudo apt-get install python-software-properties -y 

start_spinner 'Adding Deluge Repository'
sudo mkdir /dlgtmp && touch /tmp/log.txt > /dlgtmp/log.txt 2>&1
sudo add-apt-repository -y ppa:deluge-team/ppa > /dlgtmp/log.txt 2>&1
stop_spinner $?

start_spinner 'Updating Packages'
sudo apt update -yqq
stop_spinner $?

start_spinner 'Installing Deluge'
#sudo apt install deluged deluge-web -y 
stop_spinner $?
###########DELUGE USER ##############

sudo adduser --system  --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge
sudo adduser "$(whoami)" deluge
########### DAEMON SERVICE ##########

start_spinner 'Creating Deluge Daemon Service'
sudo rm deluged.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluged.service -q
sudo cp deluged.service /etc/systemd/system/


sudo systemctl daemon-reload
sudo systemctl start deluged
sudo systemctl enable deluged.service
stop_spinner $?

########### WEB-UI SERVICE ##########

start_spinner 'Creating Deluge WebUI Service'
sudo rm deluge-web.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluge-web.service -q
#echo "Creating systemd service for Deluge Web-UI..."
sudo cp deluge-web.service /etc/systemd/system/

#echo "Starting Deluge Web-UI"
sudo systemctl daemon-reload
sudo systemctl start deluge-web
sudo systemctl enable deluge-web.service
stop_spinner $?
############# OPEN PORT###############

#echo "Opening port 8112 for web access"
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
echo
echo
echo "Installation is done!"
echo
echo "You can access deluge @ http://ip-address:8112"
