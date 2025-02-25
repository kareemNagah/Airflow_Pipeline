#!/bin/bash

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

# Remove existing virtual environment if it exists
if [ -d "venv" ]; then
    echo "Removing existing virtual environment..."
    rm -rf venv
fi

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip

# Install setuptools and wheel first
echo "Installing build dependencies..."
pip install --no-cache-dir setuptools wheel

# Install other packages with preference for binary distributions
echo "Installing main dependencies..."
pip install --no-cache-dir --prefer-binary -r requirements.txt

# Verify installations
echo "Verifying installations..."
python3 -c "import numpy; import pandas; import sqlalchemy; import psycopg2" || {
    echo "Error: Some required packages failed to install"
    exit 1
}

echo "Virtual environment setup complete."
echo "To activate the environment, run: source venv/bin/activate"