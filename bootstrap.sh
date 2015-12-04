#!/usr/bin/env bash

sudo su -
cp /vagrant/hosts /etc/hosts
cp /vagrant/resolv.conf /etc/resolv.conf

systemctl enable ntpd; systemctl start ntpd
