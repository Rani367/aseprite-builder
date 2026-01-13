# Aseprite Builder

Automatically build and update [Aseprite](https://www.aseprite.org/) from source on macOS Apple Silicon.

## One-Command Install

```bash
curl -sL https://raw.githubusercontent.com/Rani367/aseprite-builder/main/update-aseprite.sh | bash
```

## Manual Install

1. Clone this repo:
   ```bash
   git clone https://github.com/Rani367/aseprite-builder.git ~/aseprite-builder
   ```

2. Run the script:
   ```bash
   ~/aseprite-builder/update-aseprite.sh
   ```

## What it does

1. Checks your installed Aseprite version
2. Fetches the latest release from GitHub
3. Downloads the source if an update is available
4. Builds using the official `build.sh` script
5. Installs to `/Applications/Aseprite.app`
6. Creates the app icon (missing from source builds)
7. Cleans up old versions

## Requirements

- macOS (Apple Silicon)
- [Homebrew](https://brew.sh/)
- Xcode Command Line Tools (`xcode-select --install`)

The script will automatically install `ninja` and `cmake` via Homebrew if missing.

## Updating

Just run the script again anytime:

```bash
~/aseprite-builder/update-aseprite.sh
```

Or use the one-liner above.

## License

This script is for personal use. Aseprite source code is licensed under the [Aseprite EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt) - free to compile for personal use, but redistribution of binaries is not allowed.
