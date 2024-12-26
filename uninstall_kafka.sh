#!/bin/bash
#--------------------------------------------------------------------
# Script to uninstall Kafka+Zookeeper on Linux
# Tested on Ubuntu 22.04, 24.12
# Developed by Alexey Beloglazov in 2024
# https://github.com/gofer064/neoflex/blob/main/uninstall_kafka.sh
#--------------------------------------------------------------------

systemctl stop zookeeper
systemctl stop kafka

systemctl disable zookeeper
systemctl disable kafka

rm /etc/systemd/system/kafka.service
rm /etc/systemd/system/zookeeper.service


systemctl daemon-reload

rm -rf /tmp/kafka*
rm -rf /opt/kafka
rm -rf /var/lib/kafka
rm -rf /var/lib/zookeeper
rm -rf /tmp/lib/kafka/kafka-logs
rm -rf /var/log/kafka
rm -rf /var/log/zookeeper

userdel kafka
