grep -q '172.31.54.10 chef-server' /etc/hosts || \
echo "
172.31.54.10 chef-server.chef-automate.com
172.31.54.11 delivery-server.chef-automate.com
172.31.54.12 build-node.chef-automate.com
" | sudo tee -a /etc/hosts