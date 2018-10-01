Installation Instruction for OrangeScrum Community edition on CentOS 7
======================================================================
*Note: This script will not work on shared hosting, only works on CentOS 7 dedicated server only.
======================================================================

Prerequisities:
===============
Hardware:
---------
RAM: minimum 2 GB 
Processor: Core2duo or Higher 
OS: CentOS 7
Disk Space: 10 GB or Higher

OS and Other required Parameters:
---------------------------------
A Fresh CentOS 7 Server
Internet Connection
Email ID
Email Password
Email SMTP Mail Server Hostname / Private Mail Server Hostname
(e.g., mail.gmail.com or smtp.yahoo.com, etc.)
SMTP Port (e.g., 25, 465, 587, etc.)

======================================================================
*Note: If Gmail ID used make sure to enable the “less secure app” fundtion. You can do this by logging into the gmail account and go to “My Accounts” then click on “Sign-in & Security” and the  enable the “Allow less secure apps: ON”.
======================================================================
*Note: Make sure to whitelist the application server domain/IP address from the private Mail Server.
======================================================================
*Note: OrangeScrum will only works on MySQL 5.4-5.7, Apache 2.4 and PHP7.x.
======================================================================

What the installation package does:
Installs required packages and dependecies to support the application
Installs and configure Apache Web Server
Installs MySQL Server, creates database and configures user for database or create database in an existing mysql setup and configures user
Setup cron jobs
configure email settings


Steps to install application:
Download the OrangeScrum Community Edition Package

Copy it to the Server’s “/tmp” directory where it will be installed.
*You can use “Winscp” of “Filezilla” to upload the package to your Server

Login to "root" or run "sudo su -" and then enter the root password.
$ sudo su -

Change the directory to "/tmp"
# cd /tmp

If unzip is not installed, please install it:
# yum install unzip

Unzip the downloaded package:
# unzip orangescrum-centos7-php7.zip

Change the directory to “orangescrum-centos7-php7”:
# cd orangescrum-centos7-php7

Make the setup.sh file executable:
# chmod +x setup.sh

Run the setup.sh file:
# ./setup

During installation if MySQL database is already installed, it will ask for root password for MySQL database, else it will ask to setup root password for new installation.

It will install all the required packages and dependecies and will ask for email ID, Email Password, SMTP mail server address and SMTP port, Domain name or IP address for the Host.

Open you browser and access the application using the domian/IP address:
http://Your_Domain_or_IP_Address
