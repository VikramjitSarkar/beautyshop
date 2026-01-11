// MongoDB script to check and update vendor hasPhysicalShop and homeServiceAvailable flags
// Run this with: node fix_vendor_flags.js

import mongoose from 'mongoose';

// Connect to MongoDB
mongoose.connect('mongodb+srv://bikramjitsarkar:bikramjitsarkar@cluster0.qd1k1.mongodb.net/beauty_shop?retryWrites=true&w=majority')
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Define schema
const vendorSchema = new mongoose.Schema({}, { strict: false });
const Vendor = mongoose.model('Vendor', vendorSchema, 'vendors');

async function checkAndFixVendors() {
  try {
    console.log('\n📋 Checking all vendors...\n');
    
    // Find all vendors
    const vendors = await Vendor.find({});
    
    console.log(`Found ${vendors.length} vendors\n`);
    
    for (const vendor of vendors) {
      console.log(`\n🏪 Vendor: ${vendor.shopName || vendor.userName}`);
      console.log(`   ID: ${vendor._id}`);
      console.log(`   hasPhysicalShop: ${vendor.hasPhysicalShop}`);
      console.log(`   homeServiceAvailable: ${vendor.homeServiceAvailable}`);
      
      // Show if both are false
      if (!vendor.hasPhysicalShop && !vendor.homeServiceAvailable) {
        console.log(`   ⚠️  WARNING: Both flags are false!`);
      }
    }
    
    // Ask which vendor to update (we'll update the most recent one with services)
    console.log('\n\n📝 Looking for vendor with ID: 69626ec7d1b752385f0f24c5');
    
    const targetVendor = await Vendor.findById('69626ec7d1b752385f0f24c5');
    
    if (targetVendor) {
      console.log(`\n✅ Found target vendor: ${targetVendor.shopName}`);
      console.log(`   Current hasPhysicalShop: ${targetVendor.hasPhysicalShop}`);
      console.log(`   Current homeServiceAvailable: ${targetVendor.homeServiceAvailable}`);
      
      // Update both to true
      targetVendor.hasPhysicalShop = true;
      targetVendor.homeServiceAvailable = true;
      
      await targetVendor.save();
      
      console.log(`\n✅ UPDATED successfully!`);
      console.log(`   New hasPhysicalShop: ${targetVendor.hasPhysicalShop}`);
      console.log(`   New homeServiceAvailable: ${targetVendor.homeServiceAvailable}`);
    } else {
      console.log('\n❌ Target vendor not found');
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
  }
}

checkAndFixVendors();
