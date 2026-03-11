use std::fs;
use std::path::Path;
use std::process::Command;

fn get_binary_path() -> std::path::PathBuf {
    let mut path = std::env::current_exe().unwrap();
    path.pop();
    if path.ends_with("deps") {
        path.pop();
    }
    path.join("clean-pack")
}

#[test]
fn test_zip_single_directory_structure() {
    let tmp_dir = tempfile::tempdir().unwrap();
    let root = tmp_dir.path();

    // Setup: create directory structure
    // input/
    //   file.txt
    //   sub/
    //     subfile.txt
    let input_dir = root.join("input");
    fs::create_dir(&input_dir).unwrap();
    fs::write(input_dir.join("file.txt"), "content").unwrap();
    fs::create_dir(input_dir.join("sub")).unwrap();
    fs::write(input_dir.join("sub").join("subfile.txt"), "subcontent").unwrap();

    // Run clean-pack zip
    let binary = get_binary_path();
    let status = Command::new(&binary)
        .arg("zip")
        .arg(&input_dir)
        .status()
        .expect("Failed to execute clean-pack");

    assert!(status.success());

    // Find the generated zip file
    let entries = fs::read_dir(root).unwrap();
    let zip_file = entries
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .find(|p| p.extension().map_or(false, |ext| ext == "zip"))
        .expect("No zip file created");

    // Verify zip contents
    let file = fs::File::open(&zip_file).unwrap();
    let mut archive = zip::ZipArchive::new(file).unwrap();

    // Check that entries start with "input/"
    let mut found_root_folder = false;
    for i in 0..archive.len() {
        let file = archive.by_index(i).unwrap();
        let name = file.name();
        if name.starts_with("input/") {
            found_root_folder = true;
        }
    }

    assert!(
        found_root_folder,
        "Zip archive should contain the root folder 'input/'"
    );
}

#[test]
fn test_targz_single_directory_structure() {
    let tmp_dir = tempfile::tempdir().unwrap();
    let root = tmp_dir.path();

    // Setup: create directory structure
    let input_dir = root.join("input_tar");
    fs::create_dir(&input_dir).unwrap();
    fs::write(input_dir.join("file.txt"), "content").unwrap();

    // Run clean-pack targz
    let binary = get_binary_path();
    let status = Command::new(&binary)
        .arg("targz")
        .arg(&input_dir)
        .status()
        .expect("Failed to execute clean-pack");

    assert!(status.success());

    // Find the generated tar.gz file
    let entries = fs::read_dir(root).unwrap();
    let tar_file = entries
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .find(|p| p.extension().map_or(false, |ext| ext == "gz")) // tar.gz ends with gz
        .expect("No tar.gz file created");

    // Verify tar contents
    let file = fs::File::open(&tar_file).unwrap();
    let tar = flate2::read::GzDecoder::new(file);
    let mut archive = tar::Archive::new(tar);

    let mut found_root_folder = false;
    for entry in archive.entries().unwrap() {
        let entry = entry.unwrap();
        let path = entry.path().unwrap();
        if path.starts_with("input_tar") {
            found_root_folder = true;
        }
    }

    assert!(
        found_root_folder,
        "Tar archive should contain the root folder 'input_tar'"
    );
}
