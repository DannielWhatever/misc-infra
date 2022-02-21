




### playing with netns

Create a rocky-linux vm to work with isolated network namespaces

- create by default a bridge network in the CIDR 172.18.0.0/16
- the root namespace will be setted to 172.18.0.1
- traffic to the outworld is allowed

- the next functions are provided
- - create-ns(netns-id, ip)
- - - Create a new network namespace and attach to the bridge
- - - e.g.: create-ns 1 172.18.0.10/16
- - in-ns(netns-name, command)
- - - Execute a command in the provided network namespace
- - - e.g.: in-ns netns-1 "ping -c1 8.8.8.8"
- - run-service(netns-id, netns-ip, port)
- - - Set up an http service in the provided network namespace
- - - e.g.: run-service 1 172.18.0.10 5000
- - allow-traffic(container-ip-and-port,host-port)
- - - Expose service in the host using the provided port
- - - e.g.: allow-traffic 172.18.0.10:5000 8080

