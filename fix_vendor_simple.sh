#!/bin/bash

# Fix the existing test vendor's flags directly via API
# Edit the password below before running

VENDOR_EMAIL="testvendor@vendor.io"
VENDOR_PASSWORD="1234abcd"
BASE_URL="https://api.thebeautyshop.io"

echo "🔧 Fixing existing vendor flags for: $VENDOR_EMAIL"

# Step 1: Login as vendor
echo "🔐 Logging in as vendor..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/vendor/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"${VENDOR_EMAIL}\",
    \"password\": \"${VENDOR_PASSWORD}\"
  }")

echo "Login response:"
echo "$LOGIN_RESPONSE" | jq '.' 2>/dev/null || echo "$LOGIN_RESPONSE"
echo ""

# Extract token (try different JSON parsers)
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Login failed or no token found."
  echo "Please update the VENDOR_PASSWORD in the script."
  exit 1
fi

echo "✅ Logged in successfully"
echo "Token: ${TOKEN:0:20}..."
echo ""

# Step 2: Update profile with correct flags
echo "🔧 Updating vendor flags..."
UPDATE_RESPONSE=$(curl -s -X PUT "${BASE_URL}/vendor/profileSetup" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"hasPhysicalShop\": \"true\",
    \"homeServiceAvailable\": \"true\"
  }")

echo "Update response:"
echo "$UPDATE_RESPONSE" | jq '.' 2>/dev/null || echo "$UPDATE_RESPONSE"
echo ""

if echo "$UPDATE_RESPONSE" | grep -q "success"; then
  echo "✅ Vendor flags updated successfully!"
  echo ""
  echo "📊 Verification - the vendor should now have:"
  echo "   - hasPhysicalShop: true"
  echo "   - homeServiceAvailable: true"
  echo ""
  echo "You can now test booking in your app!"
else
  echo "❌ Update failed. Check the response above."
  echo "Common issues:"
  echo "  - Wrong password (update VENDOR_PASSWORD in script)"
  echo "  - Vendor doesn't exist"
  echo "  - Backend issue"
fi
