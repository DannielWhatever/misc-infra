

## how to run

- ./init.sh


## clean env

- vagrant halt && vagrant destroy

## some tools

### using nerdctl
- sudo /usr/local/bin/nerdctl --namespace k8s.io inspect 88d2219566ca

### filtering weith jq
- sudo /usr/local/bin/nerdctl --namespace k8s.io inspect 88d2219566ca |jq .[0].NetworkSettings


## references (copy-paste from) : 
- - https://github.com/SKorolchuk/kubernetes-vagrant-cluster-experiments/
- - https://averagelinuxuser.com/kubernetes_containerd/