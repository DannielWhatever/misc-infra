#!/usr/bin/env bash

# swap off
swapoff -a

sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo systemctl daemon-reload
sudo mount -a 

# install some tools
sudo dnf install -y iproute-tc jq bridge-utils

# networking configurations

# # containerd files
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# #k8s files
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

sudo sysctl --system ## apply

sudo modprobe overlay
sudo modprobe br_netfilter

# update hosts file
cat >> /etc/hosts /vagrant/hosts.txt

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# install containerd
mkdir -p /etc/containerd

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y containerd.io

cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd
Documentation=https://containerd.io
After=network.target

[Service]
Type=notify
ExecStart=/usr/bin/containerd

[Install]
WantedBy=multi-user.target
EOF

containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

wget https://github.com/containerd/nerdctl/releases/download/v0.17.0/nerdctl-0.17.0-linux-amd64.tar.gz
tar Cxzvvf /usr/local/bin nerdctl-0.17.0-linux-amd64.tar.gz

# install k8s
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# enable bash-completion
sudo dnf install -y bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl

# enable kubelet
sudo systemctl enable --now kubelet