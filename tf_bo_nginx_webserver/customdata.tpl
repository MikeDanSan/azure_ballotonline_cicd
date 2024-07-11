#!/bin/bash

sudo apt-get install nginx -y #install nginx

ps -ef|grep nginx #make sure nginx is running

sudo mkdir -p /data/www #make directory for BO page install

cd /data/www #make that directory current

sudo wget bizballotonline.azurewebsites.net/website.zip #get BO website

sudo apt install unzip #install unzip package

sudo unzip website.zip -d /data/www/BallotOnline #unzip BO website

sudo chmod -R 755 /data/www/BallotOnline #modify data permissions

sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig #save orig

sudo cp /data/www/BallotOnline/nginx.conf /etc/nginx/ #update conf

sudo adduser --system --no-create-home --group nginx #add nginx user

sudo systemctl restart nginx
