use std::fs::File;
use std::io::{self, Write};
use std::path::{Path, PathBuf};

use zip::write::SimpleFileOptions;
use zip::ZipWriter;

use crate::filter::should_exclude;

/// Create a clean ZIP archive from directories or files
pub fn create_zip(source_paths: &[PathBuf], output_path: &Path) -> io::Result<()> {
    let file = File::create(output_path)?;
    let mut zip = ZipWriter::new(file);
    let options = SimpleFileOptions::default()
        .compression_method(zip::CompressionMethod::Deflated)
        .unix_permissions(0o755);

    for path in source_paths {
        // Compatibility mode: If there's only one path and it's a directory,
        // we compress its contents INCLUDING the directory itself.
        // This ensures the archive extracts into a folder, not exploding files.
        let base_path = path.parent().unwrap_or(Path::new("."));
        if path.is_dir() {
            add_directory_to_zip(&mut zip, path, base_path, options)?;
        } else {
            // Add single file
            let name = path.file_name().unwrap().to_str().unwrap();
            // Check if excluded
            if should_exclude(path) {
                continue;
            }
            let mut f = File::open(path)?;
            zip.start_file(name, options)?;
            io::copy(&mut f, &mut zip)?;
        }
    }

    zip.finish()?;
    Ok(())
}

fn add_directory_to_zip<W: Write + io::Seek>(
    zip: &mut ZipWriter<W>,
    dir: &Path,
    base_path: &Path,
    options: SimpleFileOptions,
) -> io::Result<()> {
    if !dir.is_dir() {
        // This should normally not be reached if called correctly
        return Ok(());
    }

    for entry in std::fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();

        // Skip excluded files
        if should_exclude(&path) {
            continue;
        }

        let relative_path = path.strip_prefix(base_path).unwrap();
        let name = relative_path.to_str().unwrap();

        if path.is_dir() {
            // Add directory entry
            zip.add_directory(format!("{}/", name), options)?;
            // Recursively add contents
            add_directory_to_zip(zip, &path, base_path, options)?;
        } else {
            // Add file entry
            let mut file = File::open(&path)?;
            zip.start_file(name, options)?;
            io::copy(&mut file, zip)?;
        }
    }

    Ok(())
}
