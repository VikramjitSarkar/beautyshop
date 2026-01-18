#!/bin/bash

# Deploy Payment Methods Feature
# This script deploys the payment methods functionality to the backend

echo "=== Deploying Payment Methods Feature ==="
echo ""

# Check if we're in the right directory
if [ ! -d "backend" ]; then
    echo "Error: Must run from beautyshop root directory"
    exit 1
fi

echo "Step 1: Committing changes..."
git add backend/model/Vendor.js
git add backend/controller/vendorController.js
git add backend/routes/vendorRoute.js
git add lib/views/vender/auth/payment_method_selection_screen.dart
git add lib/controllers/vendors/auth/payment_method_controller.dart
git commit -m "Add payment methods feature with backend support

- Added paymentMethods field to Vendor model
- Created updatePaymentMethods endpoint
- Fixed GetX error in payment method selection screen
- Added authentication middleware logging"

echo ""
echo "Step 2: Pushing to repository..."
git push origin main

echo ""
echo "Step 3: Deploying to server..."
SERVER="root@69.62.72.155"
BACKEND_DIR="/var/www/beautyshop/backend"

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

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Testing the API endpoint..."
sleep 2
pm2 logs beautyshop-api --lines 10
EOF

echo ""
echo "=== Deployment Successful ==="
echo ""
echo "Next steps:"
echo "1. Hot reload your Flutter app (press 'r' in terminal)"
echo "2. Register as a new vendor or go to Settings > Payment Methods"
echo "3. The payment methods screen should now work without errors"
echo ""
echo "To monitor backend logs:"
echo "ssh root@69.62.72.155 'pm2 logs beautyshop-api'"
