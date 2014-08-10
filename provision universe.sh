#!/bin/sh

apt-get update
apt-get upgrade -y
apt-get install python-software-properties software-properties-common -y
add-apt-repository ppa:bartbes/love-stable
apt-get update
apt-get install love -y
rm provision\ universe.sh
