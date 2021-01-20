#On choisit une debian
FROM debian:latest

MAINTAINER Yan LUCAS "yan.lucas@external.thalesaleniaspace.com"

#Ne pas poser de question à l'installation
ENV DEBIAN_FRONTEND noninteractive

#Variable env si proxy
ENV http_proxy="http://domain\username:password@ip:3128/"

#Installation d'apache et de php5 avec extension
RUN apt-get update \
&& apt-get -y upgrade \
&& apt-get -y install \
apache2 \
php \
php-mysql \
php-ldap \
php-xmlrpc \
php-imap \
curl \
php-curl \
php-gd \
php-mbstring \
php-xml \
php-apcu-bc \
cron \
vim \
wget

#Copie fichiers et installation initialisation de GLPI

COPY glpi-9.2.3.tgz /var/www/html/
COPY fusioninventory-9.2.2.0.tgz /var/www/html/

COPY glpi-start.sh /opt/
RUN chmod +x /opt/glpi-start.sh
ENTRYPOINT ["/opt/glpi-start.sh"]

#Exposition des ports
EXPOSE 80 443
