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

# Resize Windows partition to leave 15GB and create Linux partitions
Write-Host "Creating Linux partition scheme..."

# Get the Windows data partition (largest NTFS partition on the disk, excluding recovery partitions)
$disk = Get-Disk -Number $diskNumber
$winPartition = $disk | Get-Partition | Where-Object { $_.Type -eq 'Basic' } | ForEach-Object { 
    try { Get-Volume -Partition $_ -ErrorAction Stop } catch { $null }
} | Where-Object { $_.FileSystem -eq 'NTFS' } | Select-Object -First 1

if (-not $winPartition) {
    Write-Error "[ERR03]"
    exit 1
}

# Get partition object for resizing
$partToResize = Get-Partition -Volume $winPartition

# Calculate new size: leave 15GB for Linux partitions
$totalDiskSize = $disk.Size
$resizeSize = $totalDiskSize - 15GB

# Resize Windows partition
try {
    Resize-Partition -InputObject $partToResize -Size $resizeSize -Confirm:$false
    Write-Host "Resized Windows partition to $(($resizeSize) / 1GB -as [int])GB"
} catch {
    Write-Error "[ERR04] Failed to resize Windows partition"
    exit 1
}

# Create Linux partitions with specified sizes
# Sizes: 1GB ESP, 4GB swap, 10GB root
try {
    # Create Linux ESP partition (1GB)
    $esp = New-Partition -DiskNumber $diskNumber -Size 1GB -GptType "{ebd0a0a2-b9e5-4433-a86d-b3b64c3c2500}"
    Write-Host "Created Linux ESP partition (1GB)"
    
    # Create Linux Swap partition (4GB)
    $swap = New-Partition -DiskNumber $diskNumber -Size 4GB -GptType "{0657fd6d-a4ab-43c4-84e5-0933c84b4f4f}"
    Write-Host "Created Linux Swap partition (4GB)"
    
    # Create Linux Root partition (10GB)
    $root = New-Partition -DiskNumber $diskNumber -Size 10GB -GptType "{0fc63daf-8483-4772-8e79-3d69d8477de4}"
    Write-Host "Created Linux Root partition (10GB)"
    
    Write-Host "Linux partition scheme created successfully"
} catch {
    Write-Error "[ERR05] Failed to create Linux partitions"
    exit 1
}

start $PSScriptRoot\..\imgflash\main.exe

# System should boot into the Linux ESP, which then boots up as normal but starts post.sh when the user logs in as root.
#
# Linux system mounts:
# /dev/sda1 - Linux ESP
# /dev/sda2 - Linux swap
# /dev/sda3 - Linux root ()
# /dev/sda4 - Windows EFI (that contains the prep folder with user data and post.sh)
# /dev/sda5 - Windows partition (deleted in Linux)