#!/bin/bash

# Backend Update Script - Fix locationAddress typo
# Run this on the server after SSH connection

echo "🔍 Finding backend directory..."
BACKEND_DIR=$(find /var/www /opt /root -name "Vendor.js" -path "*/model/*" 2>/dev/null | head -1 | xargs dirname | xargs dirname)

if [ -z "$BACKEND_DIR" ]; then
    echo "❌ Backend directory not found!"
    exit 1
fi

echo "✅ Found backend at: $BACKEND_DIR"
cd "$BACKEND_DIR"

echo "📦 Creating backup..."
cp model/Vendor.js model/Vendor.js.backup.$(date +%Y%m%d_%H%M%S)

echo "🔧 Applying fix: locationAddres -> locationAddress"
sed -i 's/locationAddres:/locationAddress:/g' model/Vendor.js

echo "✅ Verifying change..."
if grep -q "locationAddress:" model/Vendor.js; then
    echo "✅ Change applied successfully!"
    grep -n "locationAddress:" model/Vendor.js
else
    echo "❌ Change verification failed!"
    exit 1
fi

echo "🔄 Restarting backend..."
pm2 restart all

echo "📋 Checking logs..."
pm2 logs --lines 20

echo "✅ Update complete!"
