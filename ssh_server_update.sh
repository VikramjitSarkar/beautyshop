#!/bin/bash

echo "🔧 Updating vendor via SSH on server..."

# Copy the update script to server and execute it there
scp /Users/bikramjitsarkar/Documents/GitHub/beautyshop/backend/update_vendor_direct.js root@69.62.72.155:/tmp/

# SSH and run the script
ssh root@69.62.72.155 << 'ENDSSH'
cd /tmp

# Create a simple Node.js script to update the vendor
cat > update_vendor.js << 'ENDSCRIPT'
const mongoose = require('mongoose');

const MONGO_URI = 'mongodb+srv://bikramjitsarkar:bikramjitsarkar@cluster0.qd1k1.mongodb.net/beauty_shop?retryWrites=true&w=majority';

async function updateVendor() {
  try {
    console.log('🔌 Connecting to MongoDB Atlas...');
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected\n');

    const Vendor = mongoose.model('Vendor', new mongoose.Schema({}, { strict: false }), 'vendors');
    
    const vendorId = '69626ec7d1b752385f0f24c5';
    
    const vendor = await Vendor.findById(vendorId);
    console.log('📋 Before update:');
    console.log('  Shop:', vendor.shopName);
    console.log('  hasPhysicalShop:', vendor.hasPhysicalShop);
    console.log('  homeServiceAvailable:', vendor.homeServiceAvailable);
    console.log('');
    
    const updated = await Vendor.findByIdAndUpdate(
      vendorId,
      { $set: { hasPhysicalShop: true, homeServiceAvailable: true } },
      { new: true }
    );
    
    console.log('✅ After update:');
    console.log('  Shop:', updated.shopName);
    console.log('  hasPhysicalShop:', updated.hasPhysicalShop);
    console.log('  homeServiceAvailable:', updated.homeServiceAvailable);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.connection.close();
    process.exit(0);
  }
}

updateVendor();
ENDSCRIPT

# Install mongoose if not present and run the script
npm install mongoose 2>/dev/null
node update_vendor.js

# Cleanup
rm update_vendor.js
ENDSSH

echo "✅ Done!"
