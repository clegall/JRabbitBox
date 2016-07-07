#!/bin/bash

# variables couleurs
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

clear
echo -e "${CBLUE}        ______        __    __    _ __  $CEND "
echo -e "${CBLUE}       / / __ \____ _/ /_  / /_  (_) /_ $CEND "
echo -e "${CBLUE}  __  / / /_/ / __ \/ __ \/ __ \/ / __/ $CEND "
echo -e "${CBLUE} / /_/ / _, _/ /_/ / /_/ / /_/ / / /_   $CEND "
echo -e "${CBLUE} \____/_/ |_|\__,_/_.___/_.___/_/\__/   $CEND "
echo -e "${CBLUE}     ____                               $CEND "
echo -e "${CBLUE}    / __ )____  _  __                   $CEND "
echo -e "${CBLUE}   / __  / __ \| |/_/                   $CEND "
echo -e "${CBLUE}  / /_/ / /_/ />  <                     $CEND "
echo -e "${CBLUE} /_____/\____/_/|_|                     $CEND "
echo -e "${CBLUE}                                        $CEND "
echo -e "${CGREEN} http://www.jrabbit.org $CEND "
echo -e "${CGREEN} Email: contact@jrabbit.org $CEND "
echo -e "${CGREEN} Author: warezcmpt $CEND "
echo -e "${CGREEN} Version: 2.0 $CEND "

#Test version Debian
VERSION1=`sed -n 1p /etc/debian_version`
VERSION=${VERSION1:0:1}

# controle droits utilisateur
var2=`sed -n 2p ~/language`
if [ $(id -u) -ne 0 ]; then
echo -e "${CRED} Sorry only root user can install JRabbitBox $CEND"
exit 1
fi


if [ $VERSION  == "8" ] ; then

#Test bonobox
folder="/var/www/base"
if [ ! -d "$folder" ] ; then
			cd /tmp
			git clone https://github.com/clegall/rutorrent-bonobox
			cd rutorrent-bonobox
			sed -i 's/reboot/#reboot/g' bonobox.sh
			sed -i 's/source-#reboot/source-reboot/g' bonobox.sh
			chmod a+x bonobox.sh
			source ./bonobox.sh
fi

#Variables
#IP Server
IPserver=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
	if [ "$IPserver" = "" ]; then
	IPserver=$(wget -qO- ipv4.icanhazip.com)
	fi

#IP Home
IPhome=($SSH_CLIENT)

#Current folder
cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Main user & mail
if [ -f "/var/www/rutorrent/histo.log" ] ; then
	#Root User
	roottest=$(sed '2q;d' /var/www/rutorrent/histo.log)
	rootuser="${roottest%%:*}"
	#Email
	email=$(sed '1q;d' /var/www/rutorrent/histo.log)
elif [ -f "/var/www/rutorrent/histo_ess.log" ] ; then
	#Root User
	roottest=$(sed '2q;d' /var/www/rutorrent/histo_ess.log)
	rootuser="${roottest%%:*}"
	#Email
	email=$(sed '1q;d' /var/www/rutorrent/histo_ess.log)
else
echo -e "${CRED} OUPS something went wrong with Bonobox install $CEND"
echo -e "${CRED} please do it again... $CEND"
exit 1
fi

rm /var/www/base/config.txt
echo "Subject: JRabbitBox Install <br>
Ip Server: $IPserver <br>
IP Home: $IPhome <br>
Email: $email <br>" >> /var/www/base/config.txt

#Install Dialog
apt-get -y --force-yes install dialog sudo

if [ ! -d "/var/www/base/index_fichiers/" ]
then

JRabbit Index
mv /var/www/base/index.html /var/www/base/bonoboxindex.html
cp -R ~/JRabbitBox/index/* /var/www/base/

#sed -i "\$awww-data ALL=(ALL) NOPASSWD:ALL" /etc/sudoers

#cp /etc/nginx/sites-enabled/rutorrent.conf /etc/nginx/sites-enabled/rutorrent.old
#sed -i '/location ^~ \/ {/,/ allow all;/d' /etc/nginx/sites-enabled/rutorrent.conf
#sed -i "/## début config accueil serveur ##/a auth_basic_user_file \"\/etc\/nginx\/passwd\/rutorrent_passwd_$rootuser\";" /etc/nginx/sites-enabled/rutorrent.conf
#sed -i '/## début config accueil serveur ##/a auth_basic \"JRabbitBox\";' /etc/nginx/sites-enabled/rutorrent.conf
#sed -i '/## début config accueil serveur ##/a #allow all;' /etc/nginx/sites-enabled/rutorrent.conf
#sed -i '/## début config accueil serveur ##/a satisfy any;' /etc/nginx/sites-enabled/rutorrent.conf
#sed -i '/## début config accueil serveur ##/a include \/etc\/nginx\/conf.d\/cache.conf;' /etc/nginx/sites-enabled/rutorrent.conf
#sed -i '/## début config accueil serveur ##/a include \/etc\/nginx\/conf.d\/php.conf;' /etc/nginx/sites-enabled/rutorrent.conf
#sed -i '/## début config accueil serveur ##/a root \/var\/www\/base;' /etc/nginx/sites-enabled/rutorrent.conf
#sed -i '/## début config accueil serveur ##/a location ^~ \/ {' /etc/nginx/sites-enabled/rutorrent.conf
#service nginx restart
#fi

#Menu
cmd=(dialog --separate-output --checklist "KolgateBox " 30 76 24)
options=(03 "CakeBox" on
25 "Plex" on
55 "Shellinabox" off
70 "Reboot" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
    case $choice in
02)
#Cakebox
chmod +x ./cakebox/cakebox.sh
source ./cakebox/cakebox.sh
cd $cwd
;;

03)
#PLEX
chmod +x ./plex/plex.sh
source ./plex/plex.sh
cd $cwd
;;

04)
#Shellinabox
chmod +x ./shellinabox/shellinabox.sh
source ./shellinabox/shellinabox.sh
cd $cwd
;;

06)
#Reboot
chmod +x reboot.sh
source reboot.sh
cd $cwd
;;

    esac
done

else
echo -e "${CRED} JRabbitBox is only supported by Debian 8 Jessie SORRY $CEND"
exit 1
fi
