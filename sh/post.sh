#!/bin/bash

# TODO: Add tar extraction code and windows cleanup

#!/bin/bash

# Below is GPT expansion to grow root. Written by Gemini and not me because its too late at night and i hate bash because its just weird.
# --- CONFIGURATION ---
DISK="/dev/sda"
PART_NUM="3"
MOUNT_POINT="/"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: Please run as root (sudo)."
   exit 1
fi

echo "--- Initializing GPT Online Expansion ---"

# 1. Install growpart (required for GPT online resizing)
if ! command -v growpart &> /dev/null; then
    echo "Installing 'growpart' (cloud-utils)..."
    sudo zypper install -y growpart || { echo "Failed to install growpart."; exit 1; }
fi

# 2. Expand the GPT partition
# growpart automatically handles moving the GPT backup header to the new end of the disk
echo "Expanding partition ${DISK}${PART_NUM}..."
sudo growpart "$DISK" "$PART_NUM"
if [[ $? -ne 0 ]]; then
    echo "Expansion failed. Ensure free space is immediately after partition ${PART_NUM}."
    exit 1
fi

# 3. Reload the partition table into the kernel
echo "Notifying kernel of partition changes..."
sudo partprobe "$DISK"

# 4. Grow the Btrfs filesystem to fill the new partition space
echo "Resizing Btrfs filesystem on ${MOUNT_POINT}..."
sudo btrfs filesystem resize max "$MOUNT_POINT"

echo "--- Finished ---"
df -h "$MOUNT_POINT"