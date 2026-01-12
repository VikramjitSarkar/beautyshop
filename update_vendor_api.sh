#!/bin/bash

# Update vendor via API
# This script logs in as the vendor and updates their profile

BASE_URL="https://api.thebeautyshop.io"
VENDOR_EMAIL="testvendor@vendor.io"
VENDOR_PASSWORD="testvendor123"  # You'll need to provide the correct password

echo "🔐 Step 1: Logging in as vendor..."

# Login to get token
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/vendor/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${VENDOR_EMAIL}\",
    \"password\": \"${VENDOR_PASSWORD}\"
  }")

echo "Login response: $LOGIN_RESPONSE"

# Extract token from response (assumes JSON response with 'token' field)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get auth token. Please check the password."
  echo "Full response: $LOGIN_RESPONSE"
  exit 1
fi

echo "✅ Got auth token"
echo ""
echo "🔧 Step 2: Updating vendor profile..."

# Update profile with boolean flags
UPDATE_RESPONSE=$(curl -s -X PUT "${BASE_URL}/vendor/profileSetup" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"hasPhysicalShop\": \"true\",
    \"homeServiceAvailable\": \"true\"
  }")

echo "Update response: $UPDATE_RESPONSE"
echo ""
echo "✅ Done! Please restart your Flutter app to see the changes."
