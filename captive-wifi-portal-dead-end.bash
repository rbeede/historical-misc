#!/bin/bash
set -e

SSID="INSERTSSIDHERE"
PASS="INSERTHERE"
WIFIINTF="wlan0"

# Ensure required packages exist (Debian/Ubuntu)
sudo apt update
sudo apt install -y hostapd dnsmasq busybox

# Stop services if they are auto-started
sudo systemctl stop hostapd || true
sudo systemctl stop dnsmasq || true

# Create captive portal HTML
sudo mkdir -p /var/www/portal
sudo tee /var/www/portal/index.html >/dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
<title>WiFi Portal</title>
<style>
body { font-family: Arial; text-align: center; margin-top: 10%; }
h1 { font-size: 48px; }
p { font-size: 32px; }
</style>
</head>
<body>
<h1>Network Notice</h1>
<p>Your device has an outdated WiFi profile establishing a default connection.<br>
Please forget the WiFi network <b>${SSID}</b> in your device settings.</p>
</body>
</html>
EOF

# Start lightweight web server
sudo busybox httpd -f -p 80 -h /var/www/portal &

# Configure hostapd (WPA2/WPA3, dual-band capable)
sudo tee /etc/hostapd/hostapd.conf >/dev/null <<EOF
interface=${WIFIINTF}
driver=nl80211
ssid=${SSID}

# WPA2/WPA3 mixed mode
wpa=2
wpa_key_mgmt=WPA-PSK SAE
rsn_pairwise=CCMP
sae_require_higher_security=1
wpa_passphrase=${PASS}

# 2.4 GHz
hw_mode=g
channel=6

# Enable 5 GHz if supported
ieee80211n=1
ieee80211ac=1
ieee80211ax=1

# Country code (required for 5GHz)
country_code=US
EOF

echo "DAEMON_CONF=/etc/hostapd/hostapd.conf" | sudo tee /etc/default/hostapd

# Configure dnsmasq (DHCP + DNS hijack)
sudo tee /etc/dnsmasq.conf >/dev/null <<EOF
interface=${WIFIINTF}
dhcp-range=10.10.0.10,10.10.0.250,12h
address=/#/10.10.0.1
EOF

# Assign static IP to AP interface
sudo ip link set ${WIFIINTF} down || true
sudo ip addr flush dev ${WIFIINTF} || true
sudo ip addr add 10.10.0.1/24 dev ${WIFIINTF}
sudo ip link set ${WIFIINTF} up

# Start hostapd + dnsmasq
sudo hostapd /etc/hostapd/hostapd.conf &
sudo dnsmasq -C /etc/dnsmasq.conf &

# iptables captive portal redirect
sudo iptables -t nat -F
sudo iptables -F

# Redirect all HTTP traffic to portal
sudo iptables -t nat -A PREROUTING -i ${WIFIINTF} -p tcp --dport 80 \
    -j DNAT --to-destination 10.10.0.1:80

# Block HTTPS to force HTTP first
sudo iptables -A FORWARD -i ${WIFIINTF} -p tcp --dport 443 -j REJECT

# NAT for clients
sudo iptables -t nat -A POSTROUTING -o ${WIFIINTF} -j MASQUERADE

echo "Captive portal AP '${SSID}' is now running."
