#!/bin/bash -eux

config_files_root=$(dirname "$(realpath "$BASH_SOURCE")")

mkdir -p ~/Downloads
mkdir -p ~/Desktop

cd ~/Downloads

installer_repo="$(cat "$config_files_root/installer-repo")"
installer_version="$(cat "$config_files_root/installer-version")"
git clone "https://$installer_repo" ImSwitchDockerInstall --no-checkout --filter=blob:none
cd ImSwitchDockerInstall
git checkout --quiet "$installer_version"

# install requirements
sudo apt-get install -y git curl

#echo "Pull and Install Docker Image"
#sudo chmod +x pull_and_run.sh
#./pull_and_run.sh

echo "Clone ImSwitchConfig"
sudo chmod +x git_clone_imswitchconfig.sh
./git_clone_imswitchconfig.sh

echo "Install HIK Driver"
sudo chmod +x install_hikdriver.sh
./install_hikdriver.sh

echo "Install Daheng Driver"
sudo chmod +x install_dahengdriver.sh
./install_dahengdriver.sh

echo "Install Vimba Driver"
sudo chmod +x install_vimba.sh
./install_vimba.sh

echo "Setup RaspAp"
sudo chmod +x install_raspap.sh
./install_raspap.sh

echo "Create Desktop Icons"
sudo chmod +x create_desktopicons.sh
./create_desktopicons.sh

echo "Set install_autostart for ImSwitch"
sudo chmod +x install_autostart.sh
./install_autostart.sh

# add serial devices to user group
sudo usermod -a -G dialout "$USER"
sudo usermod -a -G tty "$USER"
echo "Please reboot to take effect of adding serial devices to user group"
