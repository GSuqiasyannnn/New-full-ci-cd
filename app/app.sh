#!bin/bash


sudo apt install wget -y && sudo apt install unzip -y && sudo apt install nginx -y

sudo systemctl start nginx.service
cd /var/www/html
sudo wget https://www.tooplate.com/zip-templates/2130_waso_strategy.zip
sudo unzip 2130_waso_strategy.zip
cd 2130_waso_strategy
sudo cp -r * /var/www/html
sudo systemctl restart nginx.service
sudo rm -r 2130_waso_strategy && sudo rm -r 2130_waso_strategy.zip


