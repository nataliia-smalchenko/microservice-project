#!/bin/bash

set -e

echo "Starting environment setup..."

echo "Checking for essential utilities (sudo, curl, awk)..."

if ! command -v sudo &> /dev/null; then
    echo "sudo not found. Installing..."
    if [[ $EUID -eq 0 ]]; then
        if command -v apt &> /dev/null; then
            apt update && apt install -y sudo
        else
            echo "Error: No supported package manager found."
            exit 1
        fi
        echo "sudo installed successfully."
    else
        echo "Error: sudo not available and not running as root."
        echo "Please run this script as root to install sudo:"
        echo "su -c './install_dev_tools.sh'"
        exit 1
    fi
fi

install_package() {
    local package_name=$1
    if ! command -v "$package_name" &> /dev/null; then
        echo "Installing $package_name..."
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y "$package_name"
        else
            echo "Error: Could not find a suitable package manager to install $package_name."
            exit 1
        fi
    else
        echo "$package_name is already installed."
    fi
}

install_package curl
install_package awk


# Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    echo "Docker installed. Adding current user to 'docker' group (requires re-login or new terminal)."
    sudo usermod -aG docker "$USER"
    echo "Docker installed and user added to 'docker' group."
else
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo "Docker is already installed (version: $DOCKER_VERSION)."
fi

# Docker Compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo "Docker Compose is already installed (version: $COMPOSE_VERSION)."
elif docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short)
    echo "Docker Compose V2 is already installed (version: $COMPOSE_VERSION)."
else
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose V1 installed."
fi

PYTHON_VERSION=$(python3 --version 2>/dev/null | awk '{print $2}')
if [[ -z "$PYTHON_VERSION" ]] || ! python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)" 2>/dev/null;  then
    echo "Installing Python 3.9+..."
    sudo apt update
    sudo apt install -y python3 python3-pip
    PYTHON_VERSION=$(python3 --version 2>/dev/null | awk '{print $2}')
    echo "Python $PYTHON_VERSION installed."
else
    echo "Python $PYTHON_VERSION is already installed."
fi

if python3 -c "import django; print('Django', django.get_version(), 'is installed')" 2>/dev/null; then
    echo "Django is already installed."
else
    echo "Installing Django..."
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y python3-django
        echo "Django installed via apt."
    else
        echo "Warning: No suitable system package manager found for Django."
        echo "Proceeding with pip installation using --break-system-packages (NOT RECOMMENDED)."
        python3 -m pip install --upgrade pip --break-system-packages
        python3 -m pip install django --break-system-packages
        echo "Django installed via pip (with --break-system-packages)."
    fi
fi

echo "All required dependencies are set up."