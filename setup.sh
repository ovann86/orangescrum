#!/bin/bash
#Orangescrum installation in Ubuntu Server v15 and above:-
#============================================
WEBROOT=/var/www/html
APPROOT=/var/www/html/orangescrum-master
DATABASE=orangescrum
DUSER=orangescrum
DPASS=Orang3#Scrum
mysqlversion=5.6
mysqlversion1=5.5
mysqlversion2=5.7
apacheversion=2.4
phpversion=5.6
phpversion70=7.0
phpversion71=7.1
phpversion72=7.2
#mysql_v=`dpkg -l | grep "mysql.*server" | tr -s ' ' | awk 'NR == 1 || mysql' | cut -c 17-19`
mysql_v=`dpkg --get-selections | grep -i mysql.*server  | awk 'NR == 2' | cut -c 14-16`
Apache_ver=`dpkg -l | tr -s ' ' | grep -i apache2 | awk 'NR == 1 || apache2' | cut -c 12-14`
#php_ver=`dpkg -l | tr -s ' ' | grep -i php | awk 'NR == 2 || php' | cut -c 11-13`
#php_ver=`dpkg --get-selections | grep -i php | awk 'NR == 25 || php' | cut -c 4-6`
php_ver=`php -v | grep -i php | awk 'NR == 1' | cut -c 5-7` > /dev/null 2>&1
#mysql_ver=`mysql -V | awk '{ print $5 }' | cut -c 1-3` > /dev/null 2>&1
#Apache_v=`apache2 -v | grep -i Apache |awk '{ print $3 }'| cut -c 8-10`
#php_v=`php -v | grep -i php | awk 'NR == 1' | cut -c 5-7`
clear
echo "You need a fresh OS for OrangeScrum Community to work with"
echo "Orangescrum will work with MySQL 5.5-5.7, Apache Web Server 2.4 amd PHP 5.6, 7.0 & 7.2"

#MySQL-Server
if [ ! -z "$mysql_v" ]; then
	echo "Found MySQL $mysql_v on your Server"
#	echo "If you are running any other application with the current versions of MySQL, unistalling MySQL-$mysql_v might create issue"
fi

#Apache Web Server
if [ ! -z "$Apache_ver" ]; then
	echo "Found Apache Web Server $Apache_ver on your Server"
	echo "If you are running any other application with the current versions of Apache, unistalling Apache Web Server $Apache_ver might create issue"
fi

#PHP Packages on your Server
if [ ! -z "$php_ver" ]; then
	echo "Found PHP $php_ver on your Server"
	echo "If you are running any other application with the current versions of PHP, unistalling PHP-$php_ver might create issue"
fi

echo "Do you want to Continue, type Y/N"
read action

if [[ $action == "y" || $action == "Y" || $action == "yes" || $action == "Yes" ]]; then
        echo "Continue to Application Installation and Configuration"
else
        echo "Aborting Installation"
        exit 1
fi

echo "OrangeScrum Installation Started, Please Wait"
#Add Firewall rules for Apache and mysql
#echo `setenforce 0`
#echo `getenforce`
#sed -i "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config
#apt-get -y update
dpkg --configure -a

frwald=`dpkg -l | grep firewalld | tr -s ' ' | cut -c 4-12`
firwald=firewalld
if [ "$frwald" = "$firwald" ]; then
	firewall-cmd --permanent --zone=public --add-service=http
	firewall-cmd --permanent --zone=public --add-service=mysql
	firewall-cmd --permanent --zone=public --add-service=https
	firewall-cmd --reload
else
	echo "Firewalld is not installed, not setting up firewall rules"
fi

#MySQL-Server Uninstall
#mysqlver=`mysql -V | awk '{ print $5 }' | cut -c 1-3`
#if [ $mysql_ver = $mysqlversion ] || [ $mysql_ver = $mysqlversion1 ] || [ $mysql_ver = $mysqlversion2 ]; then
if [ "$mysql_v" = "$mysqlversion" ] || [ "$mysql_v" = "$mysqlversion1" ] || [ "$mysql_v" = "$mysqlversion2" ]; then
        echo "Found MySQL $mysql_v, Continue Installation"
	echo "Please enter the currently installed MySQL database root password"
	read -s DBPASS
else
        echo "Installing MySQL Server"
	apt update
	apt install -y mysql-server	
	systemctl enable mysql
	service mysql restart
	echo "Enter the MySQL root password you have create just before:"
	read -s DBPASS
	apt-get install -y expect
	echo "--> Set root password"
	echo "--> Set Security Paramaeters for MySQL"
        SECURE_MYSQL=$(expect -c "
        set timeout 10
        spawn mysql_secure_installation
        expect \"Enter current password for root (enter for none):\"
        send \"${DBPASS}\r\"
	expect \"Would you like to setup VALIDATE PASSWORD plugin?\"
        send -- \"n\r\"
        expect \"Change the password for root ?\"
        send -- \"n\r\"
        expect \"Remove anonymous users?\"
        send \"y\r\"
        expect \"Disallow root login remotely?\"
        send \"y\r\"
        expect \"Remove test database and access to it?\"
        send \"y\r\"
        expect \"Reload privilege tables now?\"
        send \"y\r\"
        expect eof
        ")
        echo "$SECURE_MYSQL"
        apt remove -y expect
fi

#Apache Web Server Uninstall older version and install required version
if [ "$Apache_ver" = "$apacheversion" ]; then
        echo "Found Apache $Apache_ver, Continue Installation"
	elif [ $Apache_ver ! = $apacheversion ]; then
        	echo "Uninstalling Apache Web Server $Apache_ver from your Server"
        	apt-get purge -y `dpkg -l | grep apache2 |awk '{print $2}'`
else
        echo "Installing Apache Web Server"
        apt install -y apache2
        systemctl enable apache2
	service apache2 restart
fi
#PHP Packages Uninstall
#if [ "$php_ver" = "$phpversion" ]; then
#        echo "Found PHP $php_ver, Continue Installation"
if [ "$php_ver" = "$phpversion70"  ] || [ "$php_ver" = "$phpversion71" ] || [ "$php_ver" = "$phpversion72" ]; then
        echo "Found PHP $php_ver, Installation will continue..."
	elif [ "$php_ver" = "$phpversion" ]; then
	        echo "Uninstalling PHP $php_ver from your Server"
		apt-get -y purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "`
		apt-get autoremove
else
	PS3='Which Version of PHP you want to Install, Please enter your choice: '
	options=("PHP 7.0" "PHP 7.2")
	select opt in "${options[@]}"
	do
	    case $opt in
        "PHP 7.0")
            echo "Installing PHP 7.0 and all the required extensions"
	    apt-get -y install libpython-stdlib libpython2.7-minimal libpython2.7-stdlib python python-apt python-minimal python-pycurl python-software-properties python2.7 python2.7-minimal
            apt install -y python-software-properties
	    apt-get -y install php7.0 php7.0-cgi php7.0-cli php7.0-common php7.0-curl php7.0-dba php7.0-fpm php7.0-gd php7.0-imap php7.0-intl php7.0-ldap php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php-imagick php-memcache php7.0-soap php7.0-tidy php7.0-xml php7.0-zip libapache2-mod-php7.0
	    service apache2 restart
	    break
            ;;
        "PHP 7.2")
            echo "Installing PHP 7.2 and all the required extensions"
	    apt-get -y install libpython-stdlib libpython2.7-minimal libpython2.7-stdlib python python-apt python-minimal python-pycurl python-software-properties python2.7 python2.7-minimal
	    add-apt-repository ppa:ondrej/php
	    apt-get update
	    apt-get -y install php7.2 php7.2-bcmath php7.2-cgi php7.2-cli php7.2-common php-curl php7.2-dba php7.2-enchant php7.2-fpm php7.2-gd php7.2-imap php7.2-intl php7.2-ldap php7.2-mbstring php-mcrypt php7.2-mysql php7.2-opcache php-imagick php-memcache php7.2-soap php7.2-tidy php7.2-xml php7.2-zip libapache2-mod-php7.2
	    service apache2 restart
	    break
            ;;
        	*) echo "invalid option $REPLY";;
	    esac
	done
#        echo "Installing PHP and all the required extensions"
#	apt install -y python-software-properties
#	add-apt-repository ppa:ondrej/php
#	apt update
#	apt install -y php5.6 php5.6-gd php5.6-curl php5.6-common php5.6-fpm php5.6-cli php5.6-gd php5.6-imap php5.6-intl php5.6-ldap php5.6-mysql php5.6-snmp php5.6-tidy php5.6-mcrypt php5.6-mbstring php5.6-soap php5.6-zip php5.6-dba php5.6 libapache2-mod-php5.6 php5.6-curl php5.6-gd php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-xml php5.6-xmlrpc
#	service apache2 restart
fi

php_version=`php -v | grep -i php | awk 'NR == 1' | cut -c 5-7`
if [ "$php_version" = "$phpversion70"  ] || [ "$php_version" = "$phpversion71" ] || [ "$php_version" = "$phpversion72" ]; then
        echo "Found PHP $php_version, Installation will continue..."
else
	echo "PHP not installed correctly, exiting setup"
	exit 1
fi

#Set application Directory
find / -name '*orangescrum-ubuntu16*' -exec mv -t $WEBROOT/ {} + > /dev/null 2>&1
mv $WEBROOT/orangescrum-ubuntu16-php7 $WEBROOT/orangescrum-master

phpadminv=`dpkg -l | grep -i phpmyadmin| awk '{print $2}' |tr "\n" " "`
phpadminver=phpMyAdmin
#Install phpMyAdmin(To access database Using UI)
#if [ "$phpversion" = "$php_version" ]; then
if [ "$php_version" = "$phpversion70"  ] || [ "$php_version" = "$phpversion71" ] || [ "$php_version" = "$phpversion72" ]; then
	echo "Installing phpMyAdmin"
	apt update
	apt install -y phpmyadmin
	phpenmod mcrypt
	phpenmod mbstring
else
	echo "PHP $phpversion not installed, phpMyAdmin will not be installed"
fi

#Installing additional required packages
htmltpdf=`dpkg -l | grep -i htmltopdf| awk '{print $2}' |tr "\n" " "`
htmlpdf=wkhtmltopdf

if [ "$htmltpdf" = "$htmlpdf" ]; then
	echo "html to pdf already installed"
else
	apt -y install xvfb libfontconfig wkhtmltopdf
fi

#To access phpmyadmin in browser and app to work properly, the following things to be changed 
#    	* Change the 'post_max_size' and `upload_max_filesize` to 200Mb in php.ini
if [ "$php_version" = "$phpversion72" ]; then
	echo "Changing PHP parameters" 
	sed -i "s/post_max_size = /; post_max_size = /g" "/etc/php/7.2/apache2/php.ini"
	sed -i "/; post_max_size = /apost_max_size = 200M" "/etc/php/7.2/apache2/php.ini"
	sed -i "s/upload_max_filesize = /; upload_max_filesize = /g" "/etc/php/7.2/apache2/php.ini"
	sed -i "/; upload_max_filesize = /aupload_max_filesize = 200M" "/etc/php/7.2/apache2/php.ini"
	sed -i "s/max_execution_time = /; max_execution_time = /g" "/etc/php/7.2/apache2/php.ini"
	sed -i "/; max_execution_time = /amax_execution_time = 300" "/etc/php/7.2/apache2/php.ini"
	sed -i "s/memory_limit = /; memory_limit = /g" "/etc/php/7.2/apache2/php.ini"
	sed -i "/; memory_limit = /amemory_limit = 512M" "/etc/php/7.2/apache2/php.ini"
	sed -i "/; max_input_vars = /amax_input_vars = 5000" "/etc/php/7.2/apache2/php.ini"
	elif [ "$php_version" = "$phpversion70" ]; then
        	echo "Changing PHP parameters" 
        	sed -i "s/post_max_size = /; post_max_size = /g" "/etc/php/7.0/apache2/php.ini"
        	sed -i "/; post_max_size = /apost_max_size = 200M" "/etc/php/7.0/apache2/php.ini"
        	sed -i "s/upload_max_filesize = /; upload_max_filesize = /g" "/etc/php/7.0/apache2/php.ini"
        	sed -i "/; upload_max_filesize = /aupload_max_filesize = 200M" "/etc/php/7.0/apache2/php.ini"
        	sed -i "s/max_execution_time = /; max_execution_time = /g" "/etc/php/7.0/apache2/php.ini"
        	sed -i "/; max_execution_time = /amax_execution_time = 300" "/etc/php/7.0/apache2/php.ini"
        	sed -i "s/memory_limit = /; memory_limit = /g" "/etc/php/7.0/apache2/php.ini"
        	sed -i "/; memory_limit = /amemory_limit = 512M" "/etc/php/7.0/apache2/php.ini"
        	sed -i "/; max_input_vars = /amax_input_vars = 5000" "/etc/php/7.0/apache2/php.ini"
else
	echo "No matched PHP versions found"	
fi

# Allow Apache to override all to make the apllication to work.
echo '# Change AllowOverride to All for the application to work
<Directory /var/www/html/>
   Options Indexes FollowSymLinks
   AllowOverride All
   Require all granted
</Directory>' >> /etc/apache2/apache2.conf

a2enmod rewrite
a2enmod headers
service apache2 restart

#mv /etc/httpd/conf.d/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf_old
#cp -f $APPROOT/phpMyAdmin.conf /etc/httpd/conf.d/
#chmod 644 /etc/httpd/conf.d/phpMyAdmin.conf

# General Configuration management: MySQL:
# If STRICT mode is On, turn it Off.
#Disable Strict mode on mysql for Centos/Fedora  :-
#Change sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES in my.cnf
#to sql_mode=""
echo '[mysqld]
sql_mode="IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"' > /etc/mysql/conf.d/disable_strict_mode.cnf
service mysql restart

#Provide proper write permission to " app/tmp ", " app/webroot " and " app/Config " folders and their sub folders.
cd $WEBROOT
chown -R www-data:www-data orangescrum-master
chmod -R 0755 orangescrum-master
cd $APPROOT
#chmod -R 0777 app/Config
chmod -R 0777 app/tmp
#chmod -R 0777 app/webroot

#Create Database and User for OS and authorize the user to the database.
mysql -uroot -p$DBPASS -e "CREATE DATABASE $DATABASE";
mysql -uroot -p$DBPASS -e "CREATE USER $DUSER@'localhost' IDENTIFIED BY '$DPASS'";
mysql -uroot -p$DBPASS -e "GRANT ALL PRIVILEGES ON $DATABASE.* TO '$DUSER'@'localhost'";

#Import database sql file:
#Navigate to application directory and import the database
cd $APPROOT
mysql -u orangescrum -p$DPASS orangescrum < database.sql

#Installing cron jobs
echo "Installing cronjobs"
echo "0 23 * * * php -q /var/www/html/orangescrum-master/app/webroot/cron_dispatcher.php /cron/email_notification" | tee -a /var/spool/cron/crontabs/root >> /dev/null
echo "*/15 * * * * php -q /var/www/html/orangescrum-master/app/webroot/cron_dispatcher.php /cron/dailyupdate_notifications" | tee -a /var/spool/cron/crontabs/root >> /dev/null
echo "*/15 * * * * php -q /var/www/html/orangescrum-master/app/webroot/cron_dispatcher.php /cron/dailyUpdateMail" | tee -a /var/spool/cron/crontabs/root >> /dev/null
echo "*/30 * * * * php -q /var/www/html/orangescrum-master/app/webroot/cron_dispatcher.php /cron/weeklyusagedetails" | tee -a /var/spool/cron/crontabs/root >> /dev/nul

echo "Please enter your email id"
read USER_NAME
echo "Please enter your email password"
read -s EPASSWD
echo "Please enter your Domain Name or IP"
read DNAME_IP
echo "Please enter your SMTP Host"
read SMTP_ADDR
echo "Please enter your SMTP port"
read SMTP_PORT

#virtualhost
cp -f $APPROOT/orangescrum.conf /etc/apache2/sites-available/
chmod 644 /etc/apache2/sites-available/orangescrum.conf
sed -i "s/ServerAdmin Email_id_of_Admin/ServerAdmin "$USER_NAME"/" "/etc/apache2/sites-available/orangescrum.conf" >> /dev/null
sed -i "s/ServerName IP_Domain name/ServerName "$DNAME_IP"/" "/etc/apache2/sites-available/orangescrum.conf" >> /dev/null
cd /etc/apache2/sites-available/
a2dissite 000-default.conf
service apache2 reload
a2ensite orangescrum.conf
service apache2 restart

#Change Email Parameters
sed -i "s/SMTP_UNAME =/SMTP_UNAME = "$USER_NAME"/" "$APPROOT/app/Config/config.ini.php"
sed -i "s/SMTP_PWORD =/SMTP_PWORD = "$EPASSWD"/" "$APPROOT/app/Config/config.ini.php"
sed -i "s/SMTP_HOST =/SMTP_HOST = ssl:\/\/"$SMTP_ADDR"/" "$APPROOT/app/Config/config.ini.php"
sed -i "s/SMTP_PORT =/SMTP_PORT = "$SMTP_PORT"/" "$APPROOT/app/Config/config.ini.php"

echo "OrangeScrum Community Edition Installation Completed Successfully."
echo "Open you browser and access the application using the domian/IP address:"
echo "http://Your_Domain_or_IP_Address/"
