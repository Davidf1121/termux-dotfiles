#!/bin/bash

# Simple script to run the Discord RPC updater

# Check for .env file
ENV_FILE="$HOME/.env"
if [ ! -f "$ENV_FILE" ] || ! grep -q "TOKEN=" "$ENV_FILE"; then
    echo "❌ Error: ~/.env file not found or TOKEN is missing."
    echo "Please create ~/.env and add your Discord token:"
    echo "TOKEN=your_token_here"
    exit 1
fi

# Install requirements if needed
if ! python -c "import requests" 2>/dev/null; then
    echo "📥 Installing requirements..."
    pip install requests
fi

python "$(dirname "$0")/discord_rpc.py"
