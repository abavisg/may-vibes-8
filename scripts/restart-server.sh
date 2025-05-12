#!/usr/bin/env bash

# Kill any running Uvicorn processes
pkill -f "uvicorn" || true

echo "Starting MindFlip backend..."

# Navigate to backend directory
cd mindflip/backend || exit 1

# Load environment variables from .env if present
if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi

# Prepare SSL certificate
CERT_DIR="$(pwd)/certs"
mkdir -p "$CERT_DIR"
KEYFILE="$CERT_DIR/key.pem"
CERTFILE="$CERT_DIR/cert.pem"
if [[ ! -f "$KEYFILE" || ! -f "$CERTFILE" ]]; then
  echo "Generating self-signed certificate..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEYFILE" -out "$CERTFILE" \
    -subj "/CN=localhost"
fi

# Start the server with HTTPS
uvicorn main:app --reload --host 0.0.0.0 --port 8000 \
  --ssl-keyfile "$KEYFILE" --ssl-certfile "$CERTFILE" 