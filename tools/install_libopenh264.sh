#!/bin/bash
# For encoding video and simulations into h264, the encoder must be installed
# user side / and separately:
# Per https://www.openh264.org/BINARY_LICENSE.txt
# It is important for the end user to be aware of 
# https://via-la.com/licensing-programs/avc-h-264/#license-fees if they intend
# to use the encoder in commercial solutions.

set -euo pipefail


if [[ "${CONFIGURE_LIBOPENH264:-}" == "true" ]]; then
    if ! dpkg -s libopenh264-dev >/dev/null 2>&1; then
        echo "Installing libopenh264-dev"
        sudo apt update
        sudo apt install -y libopenh264-dev
        sudo apt clean
        sudo rm -rf /var/lib/apt/lists/*
    else
        echo "libopenh264-dev already installed"
    fi
else
    echo "Skipping libopenh264-dev installation since CONFIGURE_LIBOPENH264 is not set to true"
fi