#!/bin/bash

# ufw_configuration.sh
# Applies the UFW firewall rules used in Task 2.
# Run with: sudo bash ufw_configuration.sh

echo "Installing UFW..."
sudo apt install ufw -y

echo "Allowing SSH (port 22) before enabling, to avoid lockout..."
sudo ufw allow ssh

echo "Enabling UFW..."
sudo ufw --force enable

echo "Denying HTTP (port 80)..."
sudo ufw deny http

echo "Allowing HTTPS (port 443)..."
sudo ufw allow https

echo "Denying Telnet (port 23)..."
sudo ufw deny 23

echo "Current UFW status:"
sudo ufw status verbose
