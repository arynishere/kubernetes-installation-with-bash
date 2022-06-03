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
function kuberinstall () {
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo " install end "
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sleep 2
echo "now install container d "
sleep 2
apt install containerd
kubeadm config images pull
echo 1 > /proc/sys/net/ipv4/ip_forward
modprobe br_netfilter
modprobe --first-time bridge

}
echo " Wellcome to Install K8S "
echo -n " do you need to K8S? (please enter yes or no) : "
read ans
if [[ $ans==yes ]];then
changeDNS
kuberinstall
reverseDNS
elif [[ $ans==no ]];then
echo " allright "
fi
