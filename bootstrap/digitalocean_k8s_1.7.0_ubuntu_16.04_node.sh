#!/usr/bin/env bash
set -e
cd ~

# ------------------------------------------------------------------------------------------------------------------------
# These values are injected into the script. We are explicitly not using a templating language to inject the values
# as to encourage the user to limit their use of templating logic in these files. By design all injected values should
# be able to be set at runtime, and the shell script real work. If you need conditional logic, write it in bash
# or make another shell script.
#
#
TOKEN="INJECTEDTOKEN"
MASTER="INJECTEDMASTER"
CA_CRT="INJECTEDCACRT"
CLUSTER_CRT="INJECTEDCLUSTERCERT"
CLUSTER_KEY="INJECTEDCLUSTERKEY"
NAME="INJECTEDNAME"
# ------------------------------------------------------------------------------------------------------------------------

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
sudo sh -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'

sudo apt-get update -y
sudo apt-get install -y \
    socat \
    ebtables \
    docker.io \
    apt-transport-https \
    kubelet \
    kubeadm=1.7.0-00

sudo systemctl enable docker
sudo systemctl start docker

sudo -E kubeadm reset
sudo -E kubeadm join --token ${TOKEN} ${MASTER}

# VPN Mesh
echo $CA_CRT > /etc/openvpn/ca.crt
echo $CLUSTER_CRT > /etc/openvpn/easy-rsa/keys/${NAME}.crt
echo $CLUSTER_KEY > /etc/openvpn/easy-rsa/keys/${NAME}.key
apt-get update -y && apt-get install openvpn -y
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/
