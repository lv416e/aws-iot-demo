#!/bin/sh
wget https://dl.grafana.com/oss/release/grafana-9.4.1-1.x86_64.rpm
sudo yum install -y grafana-9.4.1-1.x86_64.rpm
sudo grafana-cli plugins install grafana-timestream-datasource
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server