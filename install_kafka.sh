#!/bin/bash
#--------------------------------------------------------------------
# Script to Install Kafka+Zookeeper on Linux
# Tested on Ubuntu 22.04, 24.04
# Developed by Alexey Beloglazov in 2024
# 
#--------------------------------------------------------------------

#KAFKA_VERSION="2.12-3.9.0"

cd /tmp
wget https://dlcdn.apache.org/kafka/3.9.0/kafka_2.12-3.9.0.tgz
tar xvfz kafka_2.12-3.9.0.tgz
mv -f kafka_2.12-3.9.0 kafka
mv kafka /opt/
rm -rf /tmp/kafka

useradd -rs /bin/false kafka


mkdir /var/lib/kafka
chown kafka:kafka /var/lib/kafka
mkdir /var/lib/zookeeper
chown kafka:kafka /var/lib/zookeeper
mkdir -p /tmp/lib/kafka/kafka-logs
chown -R kafka:kafka /tmp/lib/kafka
mkdir /var/log/kafka
chown kafka:kafka /var/log/kafka
mkdir /var/log/zookeeper
chown kafka:kafka /var/log/zookeeper
chown -R kafka:kafka /opt/kafka/

sed -E -i 's/(dataDir=).*/\1\/var\/lib\/zookeeper/' /opt/kafka/config/zookeeper.properties
sed -E -i 's/(log.dirs=).*/\1\/tmp\/lib\/kafka\/kafka-logs/' /opt/kafka/config/server.properties

echo "export PATH=/opt/kafka/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

cat <<EOF> /etc/systemd/system/kafka.service

[Unit]
Description=Kafka
Requires=network.target remote-fs.target
After=network.target remote-fs.target zookeeper.service

[Service]
Type=simple
User=kafka
Group=kafka
Environment=JAVA_HOME=/usr CHDIR=/var/lib/kafka LOG_DIR=/var/log/kafka/log
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF> /etc/systemd/system/zookeeper.service

[Unit]
Description=Zookeeper
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
Group=kafka
Environment=ZOO_LOG_DIR=/var/log/zookeeper JAVA_HOME=/usr CHDIR=/var/lib/zookeeper
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start zookeeper
systemctl start kafka
systemctl enable zookeeper
systemctl enable kafka
systemctl status kafka