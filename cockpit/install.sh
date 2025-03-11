#!/bin/bash -eux
# Cockpit enables system administration from a web browser.

# Install cockpit
sudo -E apt-get install -y --no-install-recommends -o Dpkg::Progress-Fancy=0 \
  cockpit cockpit-networkmanager cockpit-storaged

# install cockpit-navigator
wget https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb
sudo apt install ./cockpit-navigator_0.5.10-1focal_all.deb
rm ./cockpit-navigator_0.5.10-1focal_all.deb

# Add a minimal Cockpit package for IMSwitch
sudo mkdir -p /usr/share/cockpit/imswitch

# Create a manifest.json to list IMSwitch under "Tools"
cat << 'EOF' | sudo tee /usr/share/cockpit/imswitch/manifest.json > /dev/null
{
  "version": 0,
  "tools": {
    "imswitch": {
      "label": "IMSwitch",
      "path": "index.html"
    }
  }
}
EOF

# Create the index.html with a link to open IMSwitch
cat << 'EOF' | sudo tee /usr/share/cockpit/imswitch/index.html > /dev/null
<!DOCTYPE html>
<html>
<head>
  <title>IMSwitch</title>
</head>
<body style="display: flex; justify-content: center; align-items: center; height: 100vh;">
  <a href="https://localhost:8001/imswitch/index.html?" target="_blank">
    Open IMSwitch
  </a>
</body>
</html>
EOF

echo "Installation complete. Access Cockpit at https://<IP-ADDRESS>:9090/"