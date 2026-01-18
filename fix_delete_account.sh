#!/bin/bash

# Fix Vendor Account Deletion Issue
# This script updates the backend with better logging and error handling

echo "=== Fixing Vendor Account Deletion on Server ==="
echo ""

# SSH connection details
SERVER="root@69.62.72.155"
BACKEND_DIR="/var/www/beautyshop/backend"

echo "Step 1: Committing changes locally..."
git add backend/routes/vendorRoute.js backend/controller/vendorController.js
git commit -m "Add comprehensive logging for vendor account deletion debugging"

echo "Step 2: Pushing to repository..."
git push origin main

echo "Step 3: SSH to server and deploy..."
ssh $SERVER << 'EOF'
cd /var/www/beautyshop
echo "Current directory: $(pwd)"

echo "Pulling latest changes..."
git pull origin main

echo "Restarting backend..."
cd backend
pm2 restart all

echo "Checking PM2 status..."
pm2 list

echo "Showing recent logs..."
pm2 logs --lines 20

echo "=== Deployment Complete ==="
echo ""
echo "Now try deleting a vendor account and check logs with:"
echo "ssh root@69.62.72.155"
echo "pm2 logs beautyshop-api --lines 50"
EOF

echo ""
echo "=== Update Complete ==="
echo "Test the delete account feature in the app now"
echo "Watch backend logs: ssh root@69.62.72.155 'pm2 logs beautyshop-api'"
