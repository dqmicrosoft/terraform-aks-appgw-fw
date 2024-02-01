#!/bin/bash 
BIND9CONF="/etc/bind/named.conf.options" 
sudo apt-get update && \
  sudo apt-get install bind9 -y && \
  sudo sed -i '/forwarders {/c\\tforwarders { 168.63.129.16; };' $BIND9CONF && \
  sudo sed -i '/0.0.0.0/c\' $BIND9CONF && \ 
  sudo sed -i '/\/\/ };/c\' $BIND9CONF && \ 
  sudo sed -i '/forwarders {/i \\tallow-query { any; };' $BIND9CONF && \ 
  sudo service bind9 restart