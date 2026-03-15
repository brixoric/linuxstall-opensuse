# SimpleLinux (openSUSE)
Windows program that installs openSUSE without the user having to boot into an installation USB. All user files are transferred over.

## READ!
You are required to read the legal disclaimer at [DISCLAIMER.md](DISCLAIMER.md) and agree to the terms before using this program.

## Requirements
* 15GB storage free
* Windows ESP not mounted (normally isn't)
* SATA drive (NVMe support coming in another branch or soon)

## How it works
Main installation program (C#): Prepares and runs script

Disk preparation scripts (PowerShell): Gets disks ready

Compression and formatting scripts (Rust): Compresses OneDrive and user data and flashes openSUSE image

Post install scripts (Bash): Erase windows partitions

## Dev notes
Although GitHub says its 33.8% PowerShell, 31.6% Rust, 25.2% Shell, and 9.4% Csharp is because of
the comments i have written.

TODO:
Get .img file for flashing