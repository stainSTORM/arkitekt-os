#!/bin/bash -eu
sudo apt-get install -y  curl wget

# Install Miniforge
echo "Installing Miniforge"
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh -O /tmp/miniforge.sh
sudo bash /tmp/miniforge.sh -b -p /opt/conda
rm /tmp/miniforge.sh

# Update PATH environment variable
echo "Updating PATH"
export PATH=/opt/conda/bin:$PATH

# Create conda environment and install packages
echo "Creating conda environment and installing packages"
conda create -y --name arkitekt python=3.11
conda install -n arkitekt -y
conda clean --all -f -y

# Clone the config folder
echo "Cloning Arkitekt APP"
git clone https://github.com/arkitektio-apps/dornado ~/dornado
cd ~/dornado
git checkout master
# install dependencies
source /opt/conda/bin/activate arkitekt && pip install requests numpy arkitekt-next
# TODO: Register as a service on boot
#source /opt/conda/bin/activate arkitekt && pip install -e ~/ImSwitch
