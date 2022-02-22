
# configure firewalld
sudo firewall-cmd --add-port=10250/tcp
sudo firewall-cmd --add-port=30000-32767/tcp

sudo firewall-cmd --runtime-to-permanent

# execute kubeadm join
sh /vagrant/join.sh