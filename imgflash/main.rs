use std::fs;
use std::process::Command;
use std::env;

fn main() {
    let root_img_path = "tumbleweed-rootfs-x64-gpt.img";
    let boot_img_path = "tumbleweed-efi-x64-gpt.img";
    let grub_rpm = "grub2.rpm";

    let disk_number = env::var("DISK_NUMBER")
        .expect("DISK_NUMBER environment variable not set")
        .parse::<u32>()
        .expect("Failed to parse DISK_NUMBER");
    
    println!("Flashing images to disk {}...", disk_number);
    
    if let Err(e) = flash_image(&boot_img_path, 1, disk_number) {
        eprintln!("Failed to flash boot image: {}", e);
        std::process::exit(1);
    }
    println!("Boot image flashed successfully");
    
    if let Err(e) = flash_image(&root_img_path, 3, disk_number) {
        eprintln!("Failed to flash root image: {}", e);
        std::process::exit(1);
    }
    println!("Root image flashed successfully");
    
    println!("All images flashed successfully");
}

fn flash_image(image_path: &str, partition_num: u32, disk_number: u32) -> Result<(), String> {
    if !std::path::Path::new(image_path).exists() {
        return Err(format!("Image file not found: {}", image_path));
    }

    let script = format!(
        r#"
        $image = '{}'
        $diskNum = {}
        $partNum = {}
        
        # /dev/sdaX -> \\.\Volume{{GUID}} or use physical drive
        $volumePath = "\\.\PhysicalDrive{}"
        
        try {{
            $imageStream = [System.IO.File]::OpenRead($image)
            $diskStream = [System.IO.File]::OpenWrite($volumePath)

            $bufferSize = 1024 * 1024 * 4  # 4MB buffer
            $buffer = New-Object byte[] $bufferSize
            $totalBytes = 0
            
            while (($bytesRead = $imageStream.Read($buffer, 0, $bufferSize)) -gt 0) {{
                $diskStream.Write($buffer, 0, $bytesRead)
                $totalBytes += $bytesRead
                Write-Host -NoNewline "`rFlashed $([Math]::Round($totalBytes / 1MB)) MB"
            }}
            
            $diskStream.Flush()
            $diskStream.Close()
            $imageStream.Close()
            Write-Host ""
            exit 0
        }}
        catch {{
            Write-Error $_.Exception.Message
            exit 1
        }}
        "#,
        image_path, disk_number, partition_num, disk_number
    );
    
    let output = Command::new("powershell")
        .arg("-NoProfile")
        .arg("-Command")
        .arg(script)
        .output()
        .map_err(|e| format!("Failed to execute PowerShell: {}", e))?;
    
    if !output.status.success() {
        return Err(format!(
            "PowerShell command failed: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    
    Ok(())
}