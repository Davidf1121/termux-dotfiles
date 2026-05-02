#!/bin/bash

# Simple script to run the Discord RPC updater
# Install requirements if needed
if ! python -c "import requests" 2>/dev/null; then
    echo "📥 Installing requirements..."
    pip install requests
fi

python "$(dirname "$0")/discord_rpc.py"
