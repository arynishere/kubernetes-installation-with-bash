#!/bin/bash
function changeDNS () {
  echo "changing your DNS temporarily  to shecan" 
  mv /etc/resolv.conf /etc/resolv.conf.tmp
  echo "nameserver 185.51.200.2" >> /etc/resolv.conf
  echo "nameserver 178.22.122.100" >> /etc/resolv.conf
}
function reverseDNS () {
  echo "changing your DNS back to normal"
  mv /etc/resolv.conf.tmp /etc/resolv.conf
}
function InstallDocker() {
  echo "installing Docker ..."
  sleep 2
    sudo apt-get remove docker docker-engine docker.io containerd runc -y
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg lsb-release -y

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

  echo "Done! you can use docker now"
}
function kuberinstall () {
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
apt install -y kubeadm=1.18.13-00 kubelet=1.18.13-00 kubectl=1.18.13-00
sudo apt-mark hold kubelet kubeadm kubectl

sleep 2
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system
sleep 2
#apt install containerd -y
kubeadm config images pull
#echo 1 > /proc/sys/net/ipv4/ip_forward
#modprobe br_netfilter
#modprobe --first-time bridge
echo -n "set your master node name :  "
read "x"
kubeadm init --control-plane-endpoint $x --apiserver-cert-extra-sans $x --upload-certs --pod-network-cidr=10.244.0.0/16
echo " now install flannel "
sleep 3
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
}
echo " Wellcome to Install K8S "
echo -n " do you need to K8S? (please enter yes or no) : "
read ans
if [[ $ans==yes ]];then
changeDNS
InstallDocker
kuberinstall
#reverseDNS
elif [[ $ans==no ]];then
echo " allright "
fi

