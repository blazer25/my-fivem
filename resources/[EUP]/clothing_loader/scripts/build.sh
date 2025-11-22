#!/bin/bash

echo "========================================"
echo "FiveM Clothing/EUP Auto-Builder"
echo "========================================"
echo

# Check if Node.js is available
if command -v node &> /dev/null; then
    echo "Using Node.js builder..."
    node build_clothing.js
    exit 0
fi

# Check if Python is available
if command -v python3 &> /dev/null; then
    echo "Node.js not found, using Python builder..."
    python3 build_clothing.py
    exit 0
elif command -v python &> /dev/null; then
    echo "Node.js not found, using Python builder..."
    python build_clothing.py
    exit 0
fi

# Neither found
echo "ERROR: Neither Node.js nor Python found!"
echo "Please install Node.js (https://nodejs.org/) or Python (https://python.org/)"
echo
exit 1
