#!/bin/bash

#sudo apt-get install python-software-properties -y 

yes "" | sudo add-apt-repository ppa:deluge-team/ppa

sudo apt update -y

#sudo apt upgrade -y

sudo apt install deluged deluge-web -y 

########### DAEMON SERVICE ##########

sudo rm deluged.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluged.service
sudo cp deluged.service /etc/systemd/system/

sudo systemctl start deluged
sudo systemctl enable /etc/systemd/system/deluged.service


########### WEB-UI SERVICE ##########

sudo rm deluge-web.service
wget https://raw.githubusercontent.com/e-sean/deluge/master/deluge-web.service
sudo cp deluged.service /etc/systemd/system/

sudo systemctl start deluge-web
sudo systemctl enable /etc/systemd/system/deluge-web.service

############# OPEN PORT###############

iptables -I INPUT -p tcp --dport 8112 -j ACCEPT

#####kill deluge #########
killall deluged
killall deluge-web

########User and password#############
read -p 'Enter a username for Deluge remote connection: ' usr
read -sp 'Enter a password for $usr: ' pass
echo "$usr:$pass:10" >> /var/lib/deluge/.config/deluge/auth
