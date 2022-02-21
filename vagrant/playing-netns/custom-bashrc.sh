# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

externalip="10.0.200.101"
bridge0="br0"

#@params(netns-name,command)
in-ns(){
    sudo nsenter --net=/var/run/netns/$1 $2
}

#@params(netns-id,netns-ip)
create-ns(){
    sudo ip netns add netns-$1
    sudo ip link add veth-$1 type veth peer name ceth-$1
    sudo ip link set veth-$1 up
    sudo ip link set veth-$1 master $bridge0
    sudo ip link set ceth-$1 netns netns-$1

    in-ns netns-$1 "ip link set lo up"
    in-ns netns-$1 "ip link set ceth-$1 up"
    in-ns netns-$1 "ip addr add $2 dev ceth-$1"
    in-ns netns-$1 "ip route add default via 172.18.0.1"
}

#@params(container-ip:port,host-port)
allow-traffic(){
    sudo iptables -t nat -A PREROUTING -d $externalip -p tcp -m tcp --dport $2 -j DNAT --to-destination $1
    sudo iptables -t nat -A OUTPUT -d $externalip -p tcp -m tcp --dport $2 -j DNAT --to-destination $1
}

#@params(netns-id,container-ip,container-port)
run-service(){
    sudo nohup nsenter --net=/var/run/netns/netns-$1 python3 -m http.server --bind $2 $3 &
}

export -f in-ns
export -f create-ns
export -f allow-traffic
export -f run-service