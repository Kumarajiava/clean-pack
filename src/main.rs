mod filter;
mod tar_gz;
mod zip;

use std::path::{Path, PathBuf};
use std::process::ExitCode;

use chrono::Local;
use clap::{Parser, ValueEnum};

#[derive(Parser)]
#[command(name = "CleanZipForMac")]
#[command(about = "Create clean archives without macOS junk files")]
#[command(version)]
struct Cli {
    /// Output format
    #[arg(value_enum)]
    format: Format,

    /// The directories or files to compress
    #[arg(required = true, num_args = 1..)]
    paths: Vec<PathBuf>,
}

#[derive(Clone, ValueEnum)]
enum Format {
    /// ZIP format
    Zip,
    /// TAR.GZ format
    Targz,
}

fn get_timestamp() -> String {
    Local::now().format("%y%m%d_%H%M%S").to_string()
}

fn generate_output_path(input_paths: &[PathBuf], ext: &str) -> PathBuf {
    let timestamp = get_timestamp();
    
    if input_paths.len() == 1 {
        let input = &input_paths[0];
        let name = input.file_name().unwrap().to_str().unwrap();
        let output_name = format!("{}.{}.{}", name, timestamp, ext);
        input.parent().unwrap_or(Path::new(".")).join(output_name)
    } else {
        // Use the parent directory of the first item
        let parent = input_paths[0].parent().unwrap_or(Path::new("."));
        let output_name = format!("Archive.{}.{}", timestamp, ext);
        parent.join(output_name)
    }
}

fn main() -> ExitCode {
    let cli = Cli::parse();

    // Validate input paths
    for path in &cli.paths {
        if !path.exists() {
            eprintln!("Error: Path does not exist: {}", path.display());
            return ExitCode::FAILURE;
        }
    }

    // Generate output path based on format
    let (output_path, format_name) = match cli.format {
        Format::Zip => (generate_output_path(&cli.paths, "zip"), "ZIP"),
        Format::Targz => (generate_output_path(&cli.paths, "tar.gz"), "TAR.GZ"),
    };

    println!(
        "Creating {} archive: {}",
        format_name,
        output_path.display()
    );

    // Perform compression
    let result = match cli.format {
        Format::Zip => zip::create_zip(&cli.paths, &output_path),
        Format::Targz => tar_gz::create_tar_gz(&cli.paths, &output_path),
    };

    match result {
        Ok(()) => {
            println!("Done! Archive created: {}", output_path.display());
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!("Error creating archive: {}", e);
            ExitCode::FAILURE
        }
    }
}
