#!/usr/bin/env bash


sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo modprobe br_netfilter

create-bridge(){
    ip link add $1 type bridge
    ip link set $1 up
    sudo ip addr add $2 dev $1
}

create-bridge br0 172.18.0.1/16
sudo iptables -t nat -A POSTROUTING -s 172.18.0.0/16 ! -o br0 -j MASQUERADE

