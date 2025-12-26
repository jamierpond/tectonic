#!/usr/bin/env bash

set -e

echo "Installing Tectonic from Git..."

# Detect OS and set PKG_CONFIG_PATH accordingly
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"

    # Check for Homebrew ICU (Apple Silicon path first, then Intel)
    if [ -d "/opt/homebrew/opt/icu4c/lib/pkgconfig" ]; then
        export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig:${PKG_CONFIG_PATH}"
        echo "Using Homebrew ICU at /opt/homebrew/opt/icu4c"
    elif [ -d "/usr/local/opt/icu4c/lib/pkgconfig" ]; then
        export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig:${PKG_CONFIG_PATH}"
        echo "Using Homebrew ICU at /usr/local/opt/icu4c"
    else
        echo "Warning: Homebrew ICU not found. Install with: brew install icu4c"
        exit 1
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux" ]]; then
    echo "Detected Linux"

    # Common Linux pkg-config paths for ICU
    ICU_PATHS=(
        "/usr/lib/x86_64-linux-gnu/pkgconfig"
        "/usr/lib64/pkgconfig"
        "/usr/lib/pkgconfig"
        "/usr/local/lib/pkgconfig"
    )

    ICU_FOUND=false
    for path in "${ICU_PATHS[@]}"; do
        if [ -f "$path/icu-uc.pc" ]; then
            export PKG_CONFIG_PATH="$path:${PKG_CONFIG_PATH}"
            echo "Found ICU at $path"
            ICU_FOUND=true
            break
        fi
    done

    if [ "$ICU_FOUND" = false ]; then
        echo "Warning: ICU not found in standard locations."
        echo "Install ICU development libraries:"
        echo "  Ubuntu/Debian: sudo apt-get install libicu-dev"
        echo "  RedHat/CentOS: sudo yum install libicu-devel"
        echo "  Fedora: sudo dnf install libicu-devel"
        exit 1
    fi
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Verify pkg-config can find ICU
if ! pkg-config --exists icu-uc; then
    echo "Error: pkg-config cannot find icu-uc"
    echo "PKG_CONFIG_PATH is set to: $PKG_CONFIG_PATH"
    exit 1
fi

echo "ICU libraries found successfully"
echo "Installing from GitHub repository..."

# Install from git
cargo install --git https://github.com/jamierpond/tectonic --branch jp/fix-std tectonic

echo "Installation complete!"
