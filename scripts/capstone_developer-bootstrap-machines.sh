#!/bin/bash

echo "Installing Ansible"
# Add Ansible repo
sudo apt-add-repository ppa:ansible/ansible -y >/dev/null
# Update before installing
sudo apt update -qq > /dev/null
sudo apt install ansible -y -qq > /dev/null

echo "Installing Terraform"
# Install the HashiCorp GPG key.
sudo apt-get install -y -qq gnupg software-properties-common > /dev/null
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the official HashiCorp repository to your system
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update before installing
sudo apt update -qq > /dev/null
sudo apt-get install terraform -qq -y > /dev/null

echo "Installing git"
sudo apt install git -qq -y > /dev/null
