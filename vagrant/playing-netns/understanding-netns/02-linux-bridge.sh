#!/usr/bin/env bash

############################################
# create a linux bridge to connect different netns
#
#  references:
#     - https://iximiuz.com/en/posts/container-networking-is-simple/
############################################

#to clean environment, just delete the netns
#ip netns delete netns-0

#function to execute command in netns
in-ns() {
    sudo nsenter --net=/var/run/netns/$1 $2
}

#function to create isolated netns
create-ns() {
    sudo ip netns add netns-$1
    sudo ip link add veth-$1 type veth peer name ceth-$1
    sudo ip link set veth-$1 up # don't assign ip to this one!
    sudo ip link set ceth-$1 netns netns-$1

    in-ns netns-$1 "ip link set lo up"
    in-ns netns-$1 "ip link set ceth-$1 up"
    in-ns netns-$1 "ip addr add $2 dev ceth-$1"
}

#create isolated containers
create-ns 1 172.18.0.10/16
create-ns 2 172.18.0.20/16


#create the bridge
ip link add br0 type bridge
ip link set br0 up

#attach veths to the bridge
sudo ip link set veth-1 master br0
sudo ip link set veth-2 master br0

#connectivity tests
in-ns netns-1 "ping -c2 172.18.0.20"
in-ns netns-2 "ping -c2 172.18.0.10"

#copy-paste: 
#   > Lovely! Everything works great. With this new approach, we haven't been configuring veth0 and veth1 at all. 
#   > The only two IP addresses we assigned were on the ceth0 and ceth1 ends. But since both of them are on the 
#   > same Ethernet segment (remember, we connected them to the virtual switch), there is connectivity on the L2 level:
in-ns netns-1 "ip neigh"
in-ns netns-2 "ip neigh"


# now , we have connectivity between containers, but not with the root namespace u_u


#lets asign an ip to the bridge
sudo ip addr add 172.18.0.1/16 dev br0

#add default route for every netns
in-ns netns-1 "ip route add default via 172.18.0.1"
in-ns netns-2 "ip route add default via 172.18.0.1"


#more connectivity tests
in-ns netns-1 "ping -c2 172.18.0.20"
in-ns netns-2 "ping -c2 172.18.0.10"
ping -c2 172.18.0.10
ping -c2 172.18.0.20
in-ns netns-1 "ping -c2 172.18.0.1"
in-ns netns-2 "ping -c2 172.18.0.1"

#only left the connection with the outworld!

#enable packet forwarding (like the routers)
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

#enable nt in one line using iptables
sudo iptables -t nat -A POSTROUTING -s 172.18.0.0/16 ! -o br0 -j MASQUERADE






