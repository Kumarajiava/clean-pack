mod filter;
mod tar_gz;
mod zip;

use std::path::PathBuf;
use std::process::ExitCode;

use chrono::Local;
use clap::{Parser, ValueEnum};

#[derive(Parser)]
#[command(name = "CleanZipForMac")]
#[command(about = "Create clean archives without macOS junk files")]
#[command(version)]
struct Cli {
    /// The directory to compress
    path: PathBuf,

    /// Output format
    #[arg(value_enum)]
    format: Format,
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

fn generate_output_path(input_dir: &PathBuf, ext: &str) -> PathBuf {
    let dir_name = input_dir.file_name().unwrap().to_str().unwrap();
    let timestamp = get_timestamp();
    let output_name = format!("{}.{}.{}", dir_name, timestamp, ext);
    input_dir.parent().unwrap().join(output_name)
}

fn main() -> ExitCode {
    let cli = Cli::parse();

    // Validate input path
    if !cli.path.exists() {
        eprintln!("Error: Path does not exist: {}", cli.path.display());
        return ExitCode::FAILURE;
    }

    if !cli.path.is_dir() {
        eprintln!("Error: Path is not a directory: {}", cli.path.display());
        return ExitCode::FAILURE;
    }

    // Generate output path based on format
    let (output_path, format_name) = match cli.format {
        Format::Zip => (generate_output_path(&cli.path, "zip"), "ZIP"),
        Format::Targz => (generate_output_path(&cli.path, "tar.gz"), "TAR.GZ"),
    };

    println!(
        "Creating {} archive: {}",
        format_name,
        output_path.display()
    );

    // Perform compression
    let result = match cli.format {
        Format::Zip => zip::create_zip(&cli.path, &output_path),
        Format::Targz => tar_gz::create_tar_gz(&cli.path, &output_path),
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
