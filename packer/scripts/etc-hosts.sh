#!/bin/bash -eux
echo "
172.31.54.10 chef-server.$DOMAIN chef-server
172.31.54.11 delivery.$DOMAIN delivery
" | sudo tee -a /etc/hosts
for i in $(seq 1 $BUILD_NODES);
do
  ip=$((11 + $i))
  echo "172.31.54.$ip build-node-$i.$DOMAIN build-node-$i" | sudo tee -a /etc/hosts
done

sudo sed -i'' "s/127.0.0.1 $(hostname).$DOMAIN $(hostname)//" /etc/hosts
