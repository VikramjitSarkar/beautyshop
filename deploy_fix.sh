#!/bin/bash

echo "📤 Deploying backend fix to server..."

# Copy the updated adminRoute.js to the server
scp /Users/bikramjitsarkar/Documents/GitHub/beautyshop/backend/routes/adminRoute.js root@69.62.72.155:/root/backend/routes/

echo ""
echo "✅ File copied to server"
echo ""
echo "🔄 Restarting backend service..."

# SSH and restart the backend
ssh root@69.62.72.155 << 'ENDSSH'
cd /root/backend
pm2 restart all
echo "✅ Backend restarted"
pm2 logs --lines 5
ENDSSH

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Now run: ./quick_fix_vendor.sh"
