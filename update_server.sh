#!/bin/bash

# Server Update Script - Fix Address Display Issue
# This updates the backend categoryController.js to handle both locationAddress and locationAddres field names

echo "=== Updating BeautyShop Backend on Server ==="
echo ""

# SSH connection details
SERVER="root@69.62.72.155"
BACKEND_DIR="/var/www/beautyshop/backend"

echo "Step 1: SSH to server and pull latest code..."
ssh $SERVER << 'EOF'
cd /var/www/beautyshop
echo "Current directory: $(pwd)"

echo "Pulling latest changes from git..."
git pull origin main

echo "Restarting PM2..."
cd backend
pm2 restart all

echo "Checking PM2 status..."
pm2 list

echo "=== Backend Update Complete ==="
EOF

echo ""
echo "Done! The backend has been updated."
echo "Now hot reload your Flutter app with 'R' in the terminal."
