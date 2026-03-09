use std::fs::File;
use std::io::{self, Write};
use std::path::Path;

use zip::write::SimpleFileOptions;
use zip::ZipWriter;

use crate::filter::should_exclude;

/// Create a clean ZIP archive from a directory
pub fn create_zip(source_dir: &Path, output_path: &Path) -> io::Result<()> {
    let file = File::create(output_path)?;
    let mut zip = ZipWriter::new(file);
    let options = SimpleFileOptions::default()
        .compression_method(zip::CompressionMethod::Deflated)
        .unix_permissions(0o755);

    let source_dir_str = source_dir.to_str().unwrap();

    // Add directory entries recursively
    add_directory_to_zip(&mut zip, source_dir, source_dir_str, options)?;

    zip.finish()?;
    Ok(())
}

fn add_directory_to_zip<W: Write + io::Seek>(
    zip: &mut ZipWriter<W>,
    dir: &Path,
    base_path: &str,
    options: SimpleFileOptions,
) -> io::Result<()> {
    if !dir.is_dir() {
        return Err(io::Error::new(
            io::ErrorKind::NotADirectory,
            "Source path is not a directory",
        ));
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
