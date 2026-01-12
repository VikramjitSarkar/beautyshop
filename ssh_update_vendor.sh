#!/bin/bash

# SSH Script to update vendor flags in MongoDB
# Run this from your local machine

echo "🔧 Connecting to server and updating vendor..."

ssh root@69.62.72.155 << 'EOF'
# MongoDB Update Command
mongosh beauty_shop --eval '
  db.vendors.updateOne(
    { _id: ObjectId("69626ec7d1b752385f0f24c5") },
    { 
      $set: { 
        hasPhysicalShop: true, 
        homeServiceAvailable: true 
      } 
    }
  );
  
  // Verify the update
  var vendor = db.vendors.findOne({ _id: ObjectId("69626ec7d1b752385f0f24c5") });
  print("\n✅ Updated vendor:");
  print("  Shop: " + vendor.shopName);
  print("  Email: " + vendor.email);
  print("  hasPhysicalShop: " + vendor.hasPhysicalShop);
  print("  homeServiceAvailable: " + vendor.homeServiceAvailable);
'
EOF

echo "✅ Done!"
