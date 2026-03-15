# Format the Windows EFI drive as FAT32 and copy the 'prep' folder into it

# Find the EFI partition (usually has a type 'EFI System Partition')
$efiPartition = Get-Partition | Where-Object { $_.Type -eq 'EFI System Partition' }

if (-not $efiPartition) {
    Write-Error "[ERR02]"
    exit 1
}

# Get the disk number and partition number
$diskNumber = $efiPartition.DiskNumber
$partitionNumber = $efiPartition.PartitionNumber

# Assign a temporary drive letter
$driveLetter = 'S'
$vol = Get-Volume -FileSystemLabel 'ESP'
if ($vol) {
    $driveLetter = $vol.DriveLetter
} else {
    $driveLetter = (Get-Partition -DiskNumber $diskNumber -PartitionNumber $partitionNumber | Add-PartitionAccessPath -AccessPath "$driveLetter:`\").DriveLetter
}

# Format the partition as FAT32
Format-Volume -DriveLetter $driveLetter -FileSystem FAT32 -Force -Confirm:$false

# Run the Rust applet to get targz and chrome data
start "$PSScriptRoot\..\rust\main.exe"

# Copy the 'prep' folder to the EFI partition
$prepFolder = "$PSScriptRoot\..\prepfs\prep"
$targetPath = "$driveLetter:\prep"

if (-not (Test-Path $prepFolder)) {
    Write-Error "[ERR01]"
    exit 1
}

Copy-Item -Path $prepFolder -Destination $targetPath -Recurse -Force

Write-Host "Copied prep/"

# TODO:
# Resize Windows partition to leave 15GB and flash image to the remaining space.
#
# Partition scheme:
# Formatted ESP - prep folder
# Windows partition
# 1GB ESP for Linux formatted as FAT32
# 4GB swap
# 10GB root (resized in post.sh) ( )
# 
# Notes:
#
# System should boot into the Linux ESP, which then boots up as normal but starts post.sh when the user logs in as root.
#
# Linux system mounts:
# /dev/sda1 - Linux ESP
# /dev/sda2 - Linux swap
# /dev/sda3 - Linux root ()
# /dev/sda4 - Windows EFI (that contains the prep folder with user data and post.sh)
# /dev/sda5 - Windows partition (deleted in Linux)