#!/usr/bin/env bash

# Script to run and debug the MindFlip mobile app

# Navigate to the mobile directory
echo "Navigating to mobile directory..."
cd mindflip/mobile || {
  echo "Error: mindflip/mobile directory not found."
  exit 1
}

# Run the Flutter app in debug mode
echo "Running Flutter app..."
flutter run -d 00008130-001E38641ED3803A 