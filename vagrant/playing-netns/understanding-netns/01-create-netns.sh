#!/usr/bin/env bash

############################################
# create an isollateed network namespace
#
#  note: don't use bootstrap file
#
#  references:
#     - https://iximiuz.com/en/posts/container-networking-is-simple/
############################################

#show interfaces in host
ip link

#create namespace
ip netns add netns-0

#alias to execute commands in the namespace
alias in-ns="nsenter --net=/var/run/netns/netns-0"

#show interfaces in ns
in-ns ip link

#create veth in the host
ip link add veth0 type veth peer name ceth0

#show interfaces again (new interfaces creted in hosst)
ip link

#move ceth0 to the netns
ip link set ceth0 netns netns-0

# show interfaces again
ip link
in-ns ip link

#up veth
ip link set veth0 up
ip addr add 172.18.0.11/16 dev veth0

#up the ceth
in-ns ip link set lo up
in-ns ip link set ceth0 up
in-ns ip addr add 172.18.0.10/16 dev ceth0


#connectivity tests
ping 172.18.0.10 -c2
in-ns ping -c2 172.18.0.11

ping -c2 8.8.8.8
in-ns ping -c2 8.8.8.8 # expected: Network is unreachable

#at the moment we have isolated our netns and only one entry in our route table
#this one => 172.18.0.0/16 dev ceth0 proto kernel scope link src 172.18.0.10





