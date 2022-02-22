
# set variables
export socket='/run/containerd/containerd.sock'
export cidr='10.0.1.0/24'
export cidr2='10.96.1.0/24'
export masterip=`ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
export user='vagrant'

# configure firewalld
sudo firewall-cmd --add-port=2379/tcp
sudo firewall-cmd --add-port=2380/tcp
sudo firewall-cmd --add-port=6443/tcp
sudo firewall-cmd --add-port=10250/tcp

sudo firewall-cmd --runtime-to-permanent

# setup master
kubeadm init --cri-socket=$socket --apiserver-advertise-address=$masterip --pod-network-cidr=$cidr --service-cidr=$cidr2 --ignore-preflight-errors=all

# configure KUBECONFIG
dirconfig=/home/$user/.kube
sudo --user=$user mkdir -p $dirconfig
cp -i /etc/kubernetes/admin.conf $dirconfig/config
sudo chown $(id -u $user):$(id -g $user) $dirconfig/config
export KUBECONFIG=$dirconfig/config

# install cni
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# generate join.sh file
if [ ! -d /vagrant/tmp ]
then
    mkdir /vagrant/tmp
fi
export digest=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'`
export token=`kubeadm token list | grep "default bootstrap" | awk '{print $1}'`
echo "kubeadm join --cri-socket=$socket --token $token master.localcluster:6443 --discovery-token-ca-cert-hash sha256:$digest" > /vagrant/tmp/join.sh

cat /vagrant/tmp/join.sh