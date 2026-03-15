#include <cstdlib>
#include <iostream>

void runCommand(const std::string& command) {
    int returnCode = std::system(command.c_str());
    if (returnCode != 0) {
        std::cerr << "CRITICAL: Operation exited with code " << returnCode << std::endl;
    }
}

int main() {
    std::cout << "Hello!" << std::endl;
    std::cout << "Welcome to the SimpleLinux installer for openSUSE!" << std::endl;
    std::cout << "This installer will:" << std::endl;
    std::cout << "1. Erase EFI partition" << std::endl;
    std::cout << "2. Compress user data and copy it to formatted EFI partition" << std::endl;
    std::cout << "3. Shrink Windows partition" << std::endl;
    std::cout << "4. Create openSUSE partitions" << std::endl;
    std::cout << "5. Bootstrap minimal install of openSUSE Tumbleweed" << std::endl;
    std::cout << "6. Install GRUB" << std::endl;
    std::cout << "7. Reboot and run post install script to remove Windows partitions and copy user data" << std::endl;
    std::cout << "By using this program you acknowledge and agree to the terms listed and described in DISCLAIMER.md" << std::endl;
    std::cout << "" << std::endl;
    std::cout << "Would you like to start the process?" << std::endl;
    std::string ans1 = "";
    std::cin >> ans1;
    if (ans1 != "yes") {
        std::cout << "Quitting.. Goodbye!" << std::endl;
    } else {
        std::cout << "Running PowerShell script to finish steps 1-3" << std::endl;
        runCommand("powershell.exe -ExecutionPolicy Bypass -File ..\\powershell\\disk.ps1");
    }
    return 0;
}