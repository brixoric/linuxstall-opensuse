# linuxstall-opensuse
Windows program that installs openSUSE without the user having to boot into an installation USB. All user files are transferred over

= How it works
Main installation program (C#): Prepares and runs script
Disk preparation scripts (PowerShell): Gets disks ready
Compression and formatting scripts (Rust): Compresses OneDrive and user data and flashes openSUSE image
Post install scripts (Bash): Erase windows partitions
