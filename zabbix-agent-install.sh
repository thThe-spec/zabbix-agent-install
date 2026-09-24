#! /bin/bash

# Zabbix Agent 2 Installation Script
# Install Zabbix 6.4 Agent 2 in Ubuntu 22.04

# ========================
# Helper functions
# ========================

log()    { echo "[+] $*"; }
warn()   { echo "[!] $*"; }
info()   { echo "[-] $*"; }
die()    { echo "[✗] $*" >&2; exit 1; }

# ========================
# Install Zabbix Agent 2
# ========================

if ! command -v zabbix_agent2 &>/dev/null; then
    log "Installing Zabbix Agent 2..."
    wget -q https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb \
        -O /tmp/zabbix-release.deb
    sudo dpkg -i /tmp/zabbix-release.deb
    sudo apt-get update -y
    sudo apt-get install -y zabbix-agent2 zabbix-agent2-plugin-*
else
    info "Zabbix Agent 2 already installed, skipping…"
fi


# ========================
# Ask for Zabbix Hostname
# ========================

read -p "Zabbix Hostname (name of this VM): " ZABBIX_HOSTNAME
[[ -n "$ZABBIX_HOSTNAME" ]] || die "Zabbix hostname must not be empty."

ZABBIX_HOSTNAME="${ZABBIX_HOSTNAME}"


# ========================
# Edit Zabbix config file
# ========================

# Change the Server= and ServerActive= parameters with your Zabbix Server IP!!!
ZABBIX_CONF="/etc/zabbix/zabbix_agent2.conf"
sudo sed -i "/^Server=/c\\Server=127.0.0.1" "$ZABBIX_CONF" \
    || echo "Server=127.0.0.1" | sudo tee -a "$ZABBIX_CONF"
sudo sed -i "/^ServerActive=/c\\ServerActive=127.0.0.1" "$ZABBIX_CONF" \
    || echo "ServerActive=127.0.0.1" | sudo tee -a "$ZABBIX_CONF"
sudo sed -i "/^Hostname=/c\\Hostname=${ZABBIX_HOSTNAME}" "$ZABBIX_CONF" \
    || echo "Hostname=${ZABBIX_HOSTNAME}" | sudo tee -a "$ZABBIX_CONF"


# ========================
# Start Zabbix Agent 2
# ========================

sudo systemctl enable zabbix-agent2
sudo systemctl restart zabbix-agent2
log "Zabbix Agent 2 configured: Hostname=${ZABBIX_HOSTNAME}"

