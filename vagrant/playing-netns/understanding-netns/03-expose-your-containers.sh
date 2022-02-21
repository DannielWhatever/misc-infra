#!/usr/bin/env bash

############################################
# expose a container to the outworld
#
#  references:
#     - https://iximiuz.com/en/posts/container-networking-is-simple/
############################################


bridge0=br0

create-bridge() {
    ip link add $1 type bridge
    ip link set $1 up
    sudo ip addr add $2 dev $1
}

in-ns() {
    sudo nsenter --net=/var/run/netns/$1 $2
}

create-ns() {
    sudo ip netns add netns-$1
    sudo ip link add veth-$1 type veth peer name ceth-$1
    sudo ip link set veth-$1 up
    sudo ip link set veth-$1 master $bridge0
    sudo ip link set ceth-$1 netns netns-$1

    in-ns netns-$1 "ip link set lo up"
    in-ns netns-$1 "ip link set ceth-$1 up"
    in-ns netns-$1 "ip addr add $2 dev ceth-$1"
}

create-bridge $bridge0 172.18.0.1/16

sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo iptables -t nat -A POSTROUTING -s 172.18.0.0/16 ! -o br0 -j MASQUERADE


# main


create-ns 1 172.18.0.10/16
create-ns 2 172.18.0.20/16


sudo nohup nsenter --net=/var/run/netns/netns-1 python3 -m http.server --bind 172.18.0.10 5000 & # up service
curl 172.18.0.10:5000 # works ok

curl 10.0.200.101:5000 #  fails u_u

# copy-paste: 
# we need to find a way to forward any packets arriving at port 5000 on the host's eth0 interface to 172.18.0.10:5000
# we need to publish the container's port 5000 on the host's eth0 interface. iptables to the rescue!

# External traffic
sudo iptables -t nat -A PREROUTING -d 10.0.200.101 -p tcp -m tcp --dport 5000 -j DNAT --to-destination 172.18.0.10:5000

# Local traffic (since it doesn't pass the PREROUTING chain)
sudo iptables -t nat -A OUTPUT -d 10.0.200.101 -p tcp -m tcp --dport 5000 -j DNAT --to-destination 172.18.0.10:5000

# enable iptables intercepts traffic over bridged networks
sudo modprobe br_netfilter


#connectivity tests
curl 10.0.200.101:5000