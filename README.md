# Rename Ebooks

## Overview

This project builds on [ebook-tools](https://github.com/na--/ebook-tools) and provides **two distinct and stand-alone approaches** for renaming and organizing ebooks:

1. **Metadata-Based Renaming**: Utilizes traditional metadata extraction from ebook files (such as title, author, ISBN) via `ebook-tools`. This method is effective for well-formatted files with embedded or inferable metadata.

2. **LLM-Based Renaming**: Leverages a Large Language Model (LLM) to analyze ebook content and generate context-aware filenames. Ideal for ebooks with poor or missing metadata.

Each method has its own script and configuration, and they can be used independently based on the nature of your ebook collection.


1. **Metadata-Based Renaming** (default) using traditional metadata extraction tools.
2. **LLM-Based Renaming** using a Large Language Model to infer filenames from content.

This project builds on [ebook-tools](https://github.com/na--/ebook-tools) and extends its functionality, encapsulates it and allow complex [ebook-tools] options to be captured via a JSON configuration file for simplified CLI invocation. It has an additional script for renaming, organizing, and correcting issues with ebook files caused by apparent [ebook-tools] bug(s). It uses the updated / forked Docker image `didc/ebook-tools:latest`. It was tested on Ubuntu.

The scripts include:

- `rename-ebooks.sh`: Handles renaming and metadata extraction using `organize-ebooks.sh` and `fix-matches.sh`.
- `fix-matches.sh`: Fixes issues where ebooks are placed in incorrect directories.
- `organize-ebooks.sh`: Organizes ebooks based on metadata. (A lightly modified version of the original script from `ebook-tools`.)
- `lib.sh`: Contains utility functions used by other scripts. (A lightly modified version of the original script from `ebook-tools`.)

The project utilizes `ebook-tools` in Dockerized form to process and rename books effectively. Lightly modified `ebook-tools` scripts `organize-ebooks.sh` and `lib.sh` are provided in this repo need to be in the same directory as `rename-ebooks.sh` as they are bind-mounted into the Docker container.

The provided `Dockerfile` creates directories that are bind-mounted to the host filesystem to receive successful, corrupt, "pamphlet" (short non-book documents), "uncertain" and failed e-book file output. Note that although the container directory names appear in `config.json`, any name changes need to also be reflected (manually) in the Dockerfile.

## Features

- Renames ebooks using metadata extracted from various sources.
- Corrects issues where files are placed in unnecessary subdirectories.  Determines file types based on content rather than just extensions.
- Uses a configurable JSON file for flexible behavior.
- Supports `pdf`, `epub`, `mobi`, and `txt` file formats.
- Uses Docker to simplify dependency management.

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/ngpepin/rename-ebooks.git
   cd rename-ebooks
   ```
2. Ensure dependencies are installed:
   ```sh
   sudo apt install jq docker unzip poppler-utils calibre
   ```
3. Pull the required Docker image (if not already available):
   ```sh
   docker pull didc/ebook-tools:latest
   ```


## Usage

### 1. Metadata-Based Renaming

This is the default and well-established method based on extracting embedded ebook metadata.

```bash
./rename-ebooks.sh [OPTIONS] -i /path/to/input -o /path/to/output
```

**Options**:
- `-c, --config <file>`: Use a custom JSON config file.
- `-i, --input <dir>`: Input directory.
- `-o, --output <dir>`: Output directory.
- `-f, --fresh`: Redownload the Docker image.
- `-d, --debug`: Enable debug mode.
- `-h, --help`: Show help.

### 2. LLM-Based Renaming

A newer approach that uses an LLM to understand ebook content and generate meaningful filenames.

#### Option A: Bash Script (Original)

```bash
./rename-using-llm.sh -i /path/to/input -o /path/to/output -c rename-using-llm.conf
```

#### Option B: Python/LangChain Implementation (Recommended)

```bash
./rename-using-llm-langchain.py -i /path/to/input -o /path/to/output -c rename-using-llm.conf
```

The LangChain implementation provides:
- Better structured output parsing with Pydantic models
- Improved error handling and retry logic
- Cleaner, more maintainable code
- Easier extensibility for future features

See [README-LANGCHAIN.md](README-LANGCHAIN.md) for detailed documentation.

**Configuration File (`rename-using-llm.conf`)**:
- `PROJ_DIR`: Path to the project.
- `API_ENDPOINT`: URL to the LLM chat completion endpoint (e.g., `http://localhost:4141/v1/chat/completions`).
- `MODEL`: Model name (e.g., `gpt-4.1`, `gpt-4o`)

This method is particularly useful for ebooks with ambiguous or no metadata.
### Fixing Matches

If ebooks are placed in incorrect directories (due to an `ebook-tools` issue), the main script will run (or you can manually run):
```sh
./fix-matches.sh [-i /path/to/input-directory -o /path/to/output-directory]
```
This script will:
- Detect misplaced ebooks.
- Rename them based on the correct structure.
- Move files to the correct location.
- Determine the correct file types.

## Configuration

The project uses a `config.json` file to define how books are processed. Below is the full JSON schema used:

```json
{
  "docker": {
    "mounts": {
      "input": "input",
      "output": "output",
      "corrupt": "corrupt",
      "pamphlets": "pamphlets",
      "uncertain": "uncertain",
      "failed": "failed"
    },
    "dirs": {
      "input_home": "/my-input-home",
      "input": "",
      "output_home": "/my-output-home",
      "output": "",
      "corrupt": "/Corrupt",
      "pamphlets": "/Pamphlets",
      "uncertain": "/Uncertain",
      "failed": "/Failed"
    },
    "image": "didc/ebook-tools:latest",
    "dockerfile": "",
    "remove_container": true
  },
  "script_general": {
    "verbose": false,
    "keep_metadata": true,
    "corruption_check_only": false,
    "input_extensions": "^(7z|bz2|chm|arj|cab|gz|tgz|gzip|zip|rar|xz|tar|epub|docx|odt|ods|cbr|cbz|maff|iso)$",
    "output_format": ""
  },
  "isbn": {
    "metadata_fetch_order": "Goodreads,Amazon.com,Google,ISBNDB,WorldCat xISBN,OZON.ru",
    "reorder_text_to_find_isbn": "true, 400, 50",
    "organize_without_isbn": true,
    "without-isbn-sources": "Goodreads,Amazon.com,Google"
  },
  "ocr": {
    "enabled": true,
    "lang": "eng",
    "only_first_last_pages": "7,3"
  }
}
```

## Dependencies

Ensure the following dependencies are installed:
- `jq` (for parsing JSON configs)
- `docker` (for running `ebook-tools`)
- `unzip` (for checking EPUB files)
- `poppler-utils` (for handling PDFs)
- `calibre` (for metadata extraction)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with improvements.

## License

This project is licensed under the MIT License. See `LICENSE` if included for additional details.