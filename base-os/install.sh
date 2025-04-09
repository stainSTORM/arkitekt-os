#!/bin/bash -eux
# The platform hardware configuration is for configuration specific to the underlying compute
# platform used to run the operating system. Currently the only supported platform hardware is the
# Raspberry Pi 4 running Raspberry Pi OS 11 or newer.
# Hopefully, in the future other platforms will also be supported - in which case alternative OS
# build scripts will be needed for configuration.

# Note: in general, 0 represents "success/yes/selected", while 1 represents "failed/no/unselected",
# but there is no consistent meaning. Partial documentation of raspi-commands is available at
# https://www.raspberrypi.com/documentation/computers/configuration.html, but the authoritative
# reference for commands and their parameters is at
# https://github.com/RPi-Distro/raspi-config/blob/master/raspi-config . It is discouraged to use
# raspi-config commands when a reasonable platform-independent alternative exists, because they make
# it harder for our project to enable running the PlanktoScope software on computers besides the
# Raspberry Pi. So we should avoid adding more raspi-config commands.
# From: https://github.com/PlanktoScope/PlanktoScope/blob/5b06bc29746adf73bc4edf31f47c3b5ccc2de805/software/distro/setup/base-os/setup.sh
if ! command -v raspi-config &> /dev/null; then
  echo "Warning: raspi-config is unavailable, so no RPi-specific hardware configuration will be applied!"
  exit 0
fi

# The following commands enable the SPI and I2C hardware interfaces:
sudo raspi-config nonint do_spi 0
sudo raspi-config nonint do_i2c 0

# The following command enables the serial port and serial port console.
# do_serial_cons and do_serial_hw are needed for Raspberry Pi OS 12 (bookworm) and above, while
# do_serial is needed for Raspberry Pi OS (bullseye).
DISTRO_VERSION_ID="$(. /etc/os-release && echo "$VERSION_ID")"
if [ $DISTRO_VERSION_ID -ge 12 ]; then # Support Raspberry Pi OS 12 (bookworm)
  sudo raspi-config nonint do_serial_hw 0
  sudo raspi-config nonint do_serial_cons 0
else # Support Raspberry Pi OS 11 (bullseye)
  sudo raspi-config nonint do_serial 0
fi

# The following command enables the camera on the 32-bit Raspberry Pi OS (ARMv7):
sudo raspi-config nonint do_camera 0
# The following command disables legacy camera support so that we can use libcamera:
sudo raspi-config nonint do_legacy 1



# Optional: Install filesystem packages for NTFS/exFAT
sudo apt install -y ntfs-3g exfat-fuse exfatprogs

# Remove older custom rules if they exist
sudo rm -f /etc/udev/rules.d/99-usb-mount.rules 2>/dev/null || true
sudo rm -f /etc/udev/rules.d/99-auto-udisks2.rules 2>/dev/null || true

# Create the mount script
sudo tee /usr/local/bin/automount.sh >/dev/null <<'EOF'
#!/bin/bash
DEVNAME="$1"
logger -t "AUTOMOUNT" "Handling add for /dev/$DEVNAME..."

# Give the kernel a moment to register the partition fully
sleep 2

FSTYPE="$(blkid -o value -s TYPE "/dev/$DEVNAME")"
if [ -z "$FSTYPE" ]; then
  logger -t "AUTOMOUNT" "No FS type detected for /dev/$DEVNAME, skipping."
  exit 1
fi

MOUNTPOINT="/media/$DEVNAME"
mkdir -p "$MOUNTPOINT"

case "$FSTYPE" in
    vfat|exfat)
        mount -t "$FSTYPE" -o uid=1000,gid=1000,dmask=027,fmask=137 "/dev/$DEVNAME" "$MOUNTPOINT"
        ;;
    ntfs)
        mount -t ntfs -o uid=1000,gid=1000,umask=022 "/dev/$DEVNAME" "$MOUNTPOINT"
        ;;
    ext4|ext3|ext2)
        mount -t "$FSTYPE" "/dev/$DEVNAME" "$MOUNTPOINT"
        ;;
    *)
        logger -t "AUTOMOUNT" "Unsupported filesystem $FSTYPE on /dev/$DEVNAME."
        exit 1
        ;;
esac

logger -t "AUTOMOUNT" "Mounted /dev/$DEVNAME at $MOUNTPOINT (FS=$FSTYPE)."
EOF
sudo chmod +x /usr/local/bin/automount.sh

# Create the unmount script
sudo tee /usr/local/bin/autounmount.sh >/dev/null <<'EOF'
#!/bin/bash
DEVNAME="$1"
logger -t "AUTOMOUNT" "Handling remove for /dev/$DEVNAME..."

MOUNTPOINT="/media/$DEVNAME"
umount -l "$MOUNTPOINT" 2>/dev/null || true
rmdir "$MOUNTPOINT" 2>/dev/null || true

logger -t "AUTOMOUNT" "Unmounted /dev/$DEVNAME from $MOUNTPOINT."
EOF
sudo chmod +x /usr/local/bin/autounmount.sh

# Create the udev rules
sudo tee /etc/udev/rules.d/99-automount.rules >/dev/null <<'EOF'
# When a new sdX partition is added (i.e., sda1, sdb1, etc.), run automount.sh
SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]*", ACTION=="add", ENV{ID_FS_TYPE}=="?*", RUN+="/usr/bin/systemd-run --no-block /usr/local/bin/automount.sh %k"

# When removed, unmount it
SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]*", ACTION=="remove", RUN+="/usr/bin/systemd-run --no-block /usr/local/bin/autounmount.sh %k"
EOF

# 4) Reload udev so the new rules are active
if command -v udevadm &> /dev/null; then
    # This comment is in English
    echo "Reloading udev rules"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
else
    # This comment is in English
    echo "udevadm not found, skipping reload."
fi

echo "===================================="
echo "Automount installed."
echo "Insert a USB stick. It should mount under /media/sdXY (e.g. /media/sda1)."
echo "Check logs via:  journalctl -t AUTOMOUNT -f"
