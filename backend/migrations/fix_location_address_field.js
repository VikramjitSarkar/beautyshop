/**
 * Migration Script: Fix locationAddres typo to locationAddress
 * 
 * This script fixes vendor records that have 'locationAddres' instead of 'locationAddress'
 * Run this once to fix all existing database records.
 * 
 * Usage:
 *   node backend/migrations/fix_location_address_field.js
 */

import mongoose from 'mongoose';

// Use hardcoded connection for migration - update this with your actual MongoDB URI
const MONGODB_URI = 'mongodb+srv://angelraz:Angelraz%40980@clusterbeauty.h1taf.mongodb.net/beauty?retryWrites=true&w=majority';

async function fixLocationAddressField() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(MONGODB_URI);
    console.log('Connected successfully\n');

    const db = mongoose.connection.db;
    const collection = db.collection('vendors');

    // Find all vendors with locationAddres field (typo)
    const vendorsWithTypo = await collection.find({
      locationAddres: { $exists: true }
    }).toArray();

    console.log(`Found ${vendorsWithTypo.length} vendors with 'locationAddres' field\n`);

    if (vendorsWithTypo.length === 0) {
      console.log('No vendors need fixing. All good!');
      await mongoose.connection.close();
      return;
    }

    let fixed = 0;
    let skipped = 0;
    let errors = 0;

    for (const vendor of vendorsWithTypo) {
      try {
        const updateDoc = {};
        
        // If vendor has locationAddres but NOT locationAddress, copy it over
        if (vendor.locationAddres && !vendor.locationAddress) {
          updateDoc.$set = { locationAddress: vendor.locationAddres };
          updateDoc.$unset = { locationAddres: "" };
          
          await collection.updateOne(
            { _id: vendor._id },
            updateDoc
          );
          
          console.log(`✅ Fixed vendor ${vendor._id} (${vendor.shopName || 'No name'}): "${vendor.locationAddres}"`);
          fixed++;
        } 
        // If vendor has BOTH fields, remove the typo and keep locationAddress
        else if (vendor.locationAddres && vendor.locationAddress) {
          await collection.updateOne(
            { _id: vendor._id },
            { $unset: { locationAddres: "" } }
          );
          
          console.log(`✅ Removed duplicate field from vendor ${vendor._id} (${vendor.shopName || 'No name'})`);
          fixed++;
        }
        else {
          console.log(`⏭️  Skipped vendor ${vendor._id} - already has locationAddress`);
          skipped++;
        }
      } catch (err) {
        console.error(`❌ Error fixing vendor ${vendor._id}:`, err.message);
        errors++;
      }
    }

    console.log('\n========== MIGRATION SUMMARY ==========');
    console.log(`Total vendors processed: ${vendorsWithTypo.length}`);
    console.log(`Successfully fixed: ${fixed}`);
    console.log(`Skipped: ${skipped}`);
    console.log(`Errors: ${errors}`);
    console.log('======================================\n');

    await mongoose.connection.close();
    console.log('Migration completed. Database connection closed.');
    
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

fixLocationAddressField();
