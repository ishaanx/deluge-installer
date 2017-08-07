#!/bin/bash

#sudo apt-get install python-software-properties -y 

#yes "" | sudo add-apt-repository ppa:deluge-team/ppa

#sudo apt update -y

#sudo apt upgrade -y

#sudo apt install deluged deluge-web -y 
###########DELUGE USER ##############

sudo adduser --system  --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge
sudo adduser "$(whoami)" deluge
########### DAEMON SERVICE ##########

sudo rm deluged.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluged.service
sudo cp deluged.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl start deluged
sudo systemctl enable deluged.service


########### WEB-UI SERVICE ##########


sudo rm deluge-web.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluge-web.service
sudo cp deluge-web.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl start deluge-web
sudo systemctl enable deluge-web.service

############# OPEN PORT###############

sudo iptables -I INPUT -p tcp --dport 8112 -j ACCEPT

#####kill deluge #########
killall deluged
killall deluge-web

########User and password#############
read -p 'Enter a username for Deluge remote connection: ' usr
read -sp 'Enter a password for $usr: ' pass
echo "$usr:$pass:10" >> /var/lib/deluge/.config/deluge/auth

########Allow remote ############
sudo sed -i 's/"allow_remote": false/"allow_remote": true/g' /var/lib/deluge/.config/deluge/core.conf

sudo sed -i 's/"default_daemon": "",/"default_daemon": "127.0.0.1:58846",/g' /var/lib/deluge/.config/deluge/web.conf
