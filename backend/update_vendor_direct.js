// Direct vendor update using backend's connection
import mongoose from 'mongoose';
import { Vendor } from './model/Vendor.js';
import { MONGO_URI } from './config/index.js';

async function updateVendor() {
  try {
    console.log('🔌 Connecting to MongoDB...');
    
    // Use environment variable if available, otherwise use direct connection
    // Try standard connection string if SRV fails
    const mongoUri = MONGO_URI || 'mongodb+srv://bikramjitsarkar:bikramjitsarkar@cluster0.qd1k1.mongodb.net/beauty_shop?retryWrites=true&w=majority';
    
    try {
      await mongoose.connect(mongoUri, {
        serverSelectionTimeoutMS: 5000
      });
    } catch (srvError) {
      console.log('⚠️  SRV connection failed, trying standard connection string...');
      // Fallback to standard connection string
      await mongoose.connect('mongodb://cluster0.qd1k1.mongodb.net:27017/beauty_shop?authSource=admin', {
        auth: {
          username: 'bikramjitsarkar',
          password: 'bikramjitsarkar'
        },
        serverSelectionTimeoutMS: 5000
      });
    }
    console.log('✅ Connected to MongoDB\n');

    const vendorId = '69626ec7d1b752385f0f24c5';
    
    // Find the vendor first
    const vendor = await Vendor.findById(vendorId);
    
    if (!vendor) {
      console.log('❌ Vendor not found with ID:', vendorId);
      process.exit(1);
    }
    
    console.log('📋 Current vendor data:');
    console.log('  shopName:', vendor.shopName);
    console.log('  email:', vendor.email);
    console.log('  hasPhysicalShop:', vendor.hasPhysicalShop);
    console.log('  homeServiceAvailable:', vendor.homeServiceAvailable);
    console.log('');
    
    // Update the vendor
    const updateResult = await Vendor.findByIdAndUpdate(
      vendorId,
      {
        $set: {
          hasPhysicalShop: true,
          homeServiceAvailable: true
        }
      },
      { new: true } // Return the updated document
    );
    
    console.log('✅ Vendor updated successfully!');
    console.log('📋 Updated vendor data:');
    console.log('  shopName:', updateResult.shopName);
    console.log('  email:', updateResult.email);
    console.log('  hasPhysicalShop:', updateResult.hasPhysicalShop);
    console.log('  homeServiceAvailable:', updateResult.homeServiceAvailable);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
    process.exit(0);
  }
}

updateVendor();
