use std::fs::File;
use std::io::{self, Write};
use std::path::Path;

use flate2::Compression;
use flate2::write::GzEncoder;
use tar::Builder;

use crate::filter::should_exclude;

/// Create a clean TAR.GZ archive from a directory
pub fn create_tar_gz(source_dir: &Path, output_path: &Path) -> io::Result<()> {
    let file = File::create(output_path)?;
    let encoder = GzEncoder::new(file, Compression::default());
    let mut tar = Builder::new(encoder);

    add_directory_to_tar(&mut tar, source_dir, source_dir)?;

    tar.finish()?;
    Ok(())
}

fn add_directory_to_tar<W: Write>(
    tar: &mut Builder<W>,
    dir: &Path,
    base_path: &Path,
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

        if path.is_dir() {
            // Add directory entry
            tar.append_dir(relative_path, &path)?;
            // Recursively add directory contents
            add_directory_to_tar(tar, &path, base_path)?;
        } else {
            // Add file to archive with relative path
            tar.append_path_with_name(&path, relative_path)?;
        }
    }

    Ok(())
}
