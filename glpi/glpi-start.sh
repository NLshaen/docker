#!/bin/bash

#Controle du choix de version ou prise de la latest
#[[ ! "$VERSION_GLPI" ]] \
#	&& VERSION_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest | grep tag_name | cut -d '"' -f 4)

if [[ -z "${TIMEZONE}" ]]; then echo "TIMEZONE is unset"; 
else echo "date.timezone = \"$TIMEZONE\"" > /etc/php/7.0/apache2/conf.d/timezone.ini;
fi

VERSION_GLPI="9.2.3"
VERSION_FUSIONINVENTORY="9.2.2.0"

#SRC_GLPI="https://github.com/glpi-project/glpi/releases/download/${VERSION_GLPI}/glpi-${VERSION_GLPI}.tgz"
SRC_GLPI="glpi-${VERSION_GLPI}.tgz"

TAR_GLPI="glpi-${VERSION_GLPI}.tgz"
TAR_FUSIONINVENTORY="fusioninventory-${VERSION_FUSIONINVENTORY}.tgz"

FOLDER_GLPI=glpi/
FOLDER_PLUGINS=plugins/
FOLDER_WEB=/var/www/html/
#FOLDER_PLUGINS=/var/www/html/glpi/plugins/

#check if TLS_REQCERT is present
if !(grep -q "TLS_REQCERT" /etc/ldap/ldap.conf)
then
	echo "TLS_REQCERT isn't present"
        echo -e "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf
fi

#Téléchargement et extraction des sources de GLPI
if [ "$(ls ${FOLDER_WEB}${FOLDER_GLPI})" ];
then
	echo "GLPI is already installed"
else
	echo "Installation of GLPI in ${FOLDER_WEB} in progress"
	#wget -P ${FOLDER_WEB} ${SRC_GLPI}
	tar -xzf ${FOLDER_WEB}${TAR_GLPI} -C ${FOLDER_WEB}
	rm -Rf ${FOLDER_WEB}${TAR_GLPI}
	chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_GLPI}
fi

sleep 10

#Copie des plugins
if [ -e "${FOLDER_WEB}${FOLDER_GLPI}${FOLDER_PLUGINS}" ];
then
	echo "Installation of PLUGINS in $FOLDER_PLUGINS in progress"
	tar -xf ${FOLDER_WEB}${TAR_FUSIONINVENTORY} -C ${FOLDER_WEB}
	mv -v ${FOLDER_WEB}fusioninventory ${FOLDER_WEB}${FOLDER_GLPI}${FOLDER_PLUGINS}fusioninventory
	rm -Rf ${FOLDER_WEB}${TAR_FUSIONINVENTORY}
else
	echo "Directory ${FOLDER_PLUGINS} don t exist"
fi

#Modification du vhost par défaut
echo -e "<VirtualHost *:80>\n\tDocumentRoot /var/www/html/glpi\n\tServerName GLPI\n\n\t<Directory /var/www/html/glpi>\n\t\tAllowOverride All\n\t\tOrder Allow,Deny\n\t\tAllow from all\n\t</Directory>\n\n\tErrorLog /var/log/apache2/error-glpi.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access-glpi.log combined\n</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

#Add scheduled task by cron and enable
echo "*/2 * * * * www-data /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null" >> /etc/cron.d/glpi
#Start cron service
service cron start

#Activation du module rewrite d'apache
a2enmod rewrite && service apache2 restart && service apache2 stop

#Lancement du service apache au premier plan
/usr/sbin/apache2ctl -D FOREGROUND
