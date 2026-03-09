use std::fs::File;
use std::io::{self, Write};
use std::path::{Path, PathBuf};

use flate2::Compression;
use flate2::write::GzEncoder;
use tar::Builder;

use crate::filter::should_exclude;

/// Create a clean TAR.GZ archive from directories or files
pub fn create_tar_gz(source_paths: &[PathBuf], output_path: &Path) -> io::Result<()> {
    let file = File::create(output_path)?;
    let encoder = GzEncoder::new(file, Compression::default());
    let mut tar = Builder::new(encoder);

    for path in source_paths {
        if source_paths.len() == 1 && path.is_dir() {
            // Compatibility mode: content of the directory at root
            add_directory_to_tar(&mut tar, path, path)?;
        } else {
            // Multi-mode or single file: include the item itself
            let base_path = path.parent().unwrap_or(Path::new("."));
            if path.is_dir() {
                add_directory_to_tar(&mut tar, path, base_path)?;
            } else {
                // Add single file
                if should_exclude(path) {
                    continue;
                }
                let relative_path = path.file_name().unwrap();
                tar.append_path_with_name(path, relative_path)?;
            }
        }
    }

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
