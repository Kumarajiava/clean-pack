use std::path::Path;

/// Check if a file or directory should be excluded from the archive
pub fn should_exclude(path: &Path) -> bool {
    let file_name = match path.file_name().and_then(|n| n.to_str()) {
        Some(name) => name,
        None => return false,
    };

    // Exclude .DS_Store files
    if file_name == ".DS_Store" {
        return true;
    }

    // Exclude AppleDouble files (._*)
    if file_name.starts_with("._") {
        return true;
    }

    // Exclude __MACOSX directory
    if file_name == "__MACOSX" {
        return true;
    }

    // Check if any component in the path is __MACOSX
    for component in path.components() {
        if let std::path::Component::Normal(os_str) = component {
            if os_str.to_str() == Some("__MACOSX") {
                return true;
            }
        }
    }

    false
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_exclude_ds_store() {
        assert!(should_exclude(Path::new(".DS_Store")));
        assert!(should_exclude(Path::new("folder/.DS_Store")));
    }

    #[test]
    fn test_exclude_apple_double() {
        assert!(should_exclude(Path::new("._file.txt")));
        assert!(should_exclude(Path::new("folder/._image.jpg")));
    }

    #[test]
    fn test_exclude_macosx() {
        assert!(should_exclude(Path::new("__MACOSX")));
        assert!(should_exclude(Path::new("__MACOSX/file.txt")));
    }

    #[test]
    fn test_include_normal_files() {
        assert!(!should_exclude(Path::new("file.txt")));
        assert!(!should_exclude(Path::new("folder/image.jpg")));
        assert!(!should_exclude(Path::new("src/main.rs")));
    }
}
