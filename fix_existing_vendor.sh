#!/bin/bash

# Fix the existing test vendor's flags directly via API
# This uses the vendor's login and ProfileSetup endpoint

echo "🔧 Fixing existing vendor flags..."

VENDOR_EMAIL="testvendor@vendor.io"
BASE_URL="https://api.thebeautyshop.io"

# You need to provide the vendor's password
read -sp "Enter password for $VENDOR_EMAIL: " VENDOR_PASSWORD
echo ""

# Step 1: Login as vendor
echo "🔐 Logging in as vendor..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/vendor/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${VENDOR_EMAIL}\",
    \"password\": \"${VENDOR_PASSWORD}\"
  }")

# Extract token
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed. Response:"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo "✅ Logged in successfully"

# Step 2: Update profile with correct flags
echo "🔧 Updating vendor flags..."
UPDATE_RESPONSE=$(curl -s -X PUT "${BASE_URL}/vendor/profileSetup" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"hasPhysicalShop\": \"true\",
    \"homeServiceAvailable\": \"true\"
  }")

echo "Response: $UPDATE_RESPONSE"

if echo "$UPDATE_RESPONSE" | grep -q "success"; then
  echo "✅ Vendor flags updated successfully!"
  echo ""
  echo "Now you can test booking in your app."
else
  echo "❌ Update failed. Check the response above."
fi
