
# LLM-Augmented Renaming of Publications - Ready for RAG applications

## Overview

This project provides two main approaches for renaming and organizing publications:

1. **Metadata-Based Renaming**: Uses traditional metadata extraction (title, author, ISBN) via `ebook-tools` and related scripts.
2. **LLM-Based Renaming**: Uses a Language Model (LLM) API to extract metadata from publication content and generate context-aware filenames, especially for files with poor or missing metadata.

Supported formats: PDF, EPUB, CHM, MOBI.  

**We have found this to be very useful for RAG pipelines requiring ingestion of publications (e.g., required for base domain knowledge or reflecting firm-specific research publications) that may contain missing or inconsistent metadata... and where file naming provides little or no insight re: content.**

## Features

- Scans directories for supported publication files.
- Extracts text using `pdftotext` or `ebook-convert`.
- Sends extracted text to an LLM API for metadata extraction.
- Renames files using the returned metadata, with cleaning and collision avoidance.
- Converts CHM/MOBI files to PDF if needed.
- Moves unprocessable files to a "Failed" directory.
- Logs all actions and errors.
- Includes error handling and retry logic for API requests.
- Configuration via `.conf` and `config.json` files.

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/ngpepin/rename-ebooks.git
   cd rename-ebooks
   ```
2. Install dependencies:
   ```sh
   sudo apt install jq docker unzip poppler-utils calibre
   ```
3. Pull the required Docker image:
   ```sh
   docker pull didc/ebook-tools:latest
   ```

## Usage

### Metadata-Based Renaming

```bash
./rename-ebooks.sh [OPTIONS] -i /path/to/input -o /path/to/output
```

### LLM-Based Renaming

```bash
./rename-using-llm.sh /path/to/books
```
or
```bash
./rename-using-llm-langchain.py -i /path/to/input -o /path/to/output -c rename-using-llm.conf
```

- Configure `rename-using-llm.conf` with your project directory, API endpoint, and model name.

### Fixing Matches

```sh
./fix-matches.sh [-i /path/to/input-directory -o /path/to/output-directory]
```

## Configuration

See `config.json` and `.conf` files for options and API settings.

## Dependencies

- `jq`
- `docker`
- `unzip`
- `poppler-utils`
- `calibre`

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License.
