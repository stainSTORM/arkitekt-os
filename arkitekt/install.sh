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
# Comment in English: install requests and numpy after creating the environment
conda install -n arkitekt -y requests numpy
conda clean --all -f -y


# Clone the config folder
echo "Cloning Arkitekt APP"
git clone https://github.com/stainSTORM/dornado/ ~/dornado
cd ~/dornado
# install dependencies
source /opt/conda/bin/activate arkitekt && pip install arkitekt-next rekuest-next
# TODO: Register as a service on boot
#source /opt/conda/bin/activate arkitekt && pip install -e ~/ImSwitch


# Activate environment and make it persistent in ~/.bashrc
echo "Adding environment activation to ~/.bashrc"
if ! grep -Fxq "source /opt/conda/bin/activate arkitekt" ~/.bashrc; then
    echo "source /opt/conda/bin/activate arkitekt" >> ~/.bashrc
    echo "Environment activation added to ~/.bashrc"
else
    echo "Environment activation already exists in ~/.bashrc"
fi
