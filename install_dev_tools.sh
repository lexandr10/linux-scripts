#!/bin/bash


set -e


check_command() {
    command -v "$1" >/dev/null 2>$1
}

echo "Checking dpkg lock..."
dpkg --configure -a || true

if check_command docker; then
    echo "Docker already downloaded"
else 
    echo "Downloading Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi


if check_command docker-compose; then
    echo "Docker Compose already downloaded"
else
    echo "Downloading Docker Compose..."
    sudo apt install -y docker-compose
fi


if check_command python3; then
    PYTHON_VERSION=$(python3 -V 2>&1 | awk '{print $2}')
    echo "Python version $PYTHON_VERSION already installed"
else
    echo "Installing Python3..."
    apt install -y python3
fi

if is_installed pip3; then
    echo "pip already installed"
else
    echo "Installing pip..."
    apt install -y python3-pip
fi

if python3 -m django --version >/dev/null 2>&1; then
    echo "Django already downloaded"
else 
    echo "Downloading Django..."
    python3 -m pip install --user django
fi

echo "Upload successful"