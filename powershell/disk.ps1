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

# Copy the 'prep' folder to the EFI partition
$prepFolder = "$PSScriptRoot\..\rust\prep"
$targetPath = "$driveLetter:\prep"

if (-not (Test-Path $prepFolder)) {
    Write-Error "[ERR01]"
    exit 1
}

Copy-Item -Path $prepFolder -Destination $targetPath -Recurse -Force

Write-Host "Filesystem prep done."

# TODO:
# Resize Windows partition to leave 10GB and flash image to the remaining space.