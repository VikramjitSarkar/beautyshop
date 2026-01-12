#!/bin/bash

# Quick fix for vendor flags using the new admin endpoint
# No authentication needed for this temporary debug endpoint

echo "🔧 Updating vendor via API..."

RESPONSE=$(curl -s -X POST "https://api.thebeautyshop.io/admin/quickFixVendor" \
  -H "Content-Type: application/json" \
  -d '{
    "vendorId": "69626ec7d1b752385f0f24c5",
    "hasPhysicalShop": true,
    "homeServiceAvailable": true
  }')

echo "Response: $RESPONSE"

# Check if successful
if echo "$RESPONSE" | grep -q '"status":"success"'; then
  echo ""
  echo "✅ SUCCESS! Vendor flags updated."
  echo "   hasPhysicalShop: true"
  echo "   homeServiceAvailable: true"
  echo ""
  echo "Please restart your Flutter app to see the changes."
else
  echo ""
  echo "❌ Update failed. The endpoint might need to be deployed first."
  echo "   You need to restart the backend server on 69.62.72.155"
fi
