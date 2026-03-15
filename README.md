# linuxstall-opensuse
Windows program that installs openSUSE without the user having to boot into an installation USB. All user files are transferred over

## Disclaimer
WIP

## Requirements
WIP

## How it works
Main installation program (C#): Prepares and runs script

Disk preparation scripts (PowerShell): Gets disks ready

Compression and formatting scripts (Rust): Compresses OneDrive and user data and flashes openSUSE image

Post install scripts (Bash): Erase windows partitions

## Dev notes
Although GitHub says its 33.8% PowerShell, 31.6% Rust, 25.2% Shell, and 9.4% Csharp is because of
the comments i have written.