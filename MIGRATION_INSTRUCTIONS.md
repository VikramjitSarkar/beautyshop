# Database Migration Instructions

## Issue
Some vendor records in the database have `locationAddres` (missing final 's') instead of `locationAddress`. This causes addresses not to display correctly in the Flutter app.

## Solution

### Option 1: SSH to Production Server

```bash
# SSH to server
ssh root@69.62.72.155

# Navigate to backend directory
cd /var/www/beautyshop/backend

# Upload the migration script (if not already there)
# migrations/fix_location_address_field.js

# Run the migration
node migrations/fix_location_address_field.js
```

### Option 2: Run from Local Machine (if VPN connected)

```bash
cd backend
node migrations/fix_location_address_field.js
```

### Option 3: Manual Database Fix via MongoDB Compass

1. Connect to: `mongodb+srv://angelraz:Angelraz@980@clusterbeauty.h1taf.mongodb.net/beauty`
2. Go to the `vendors` collection
3. Run this update query:

```javascript
// Find all vendors with locationAddres field
db.vendors.find({ locationAddres: { $exists: true } })

// For each vendor, run this update:
db.vendors.updateMany(
  { 
    locationAddres: { $exists: true },
    locationAddress: { $exists: false }
  },
  {
    $rename: { "locationAddres": "locationAddress" }
  }
)

// Remove duplicate locationAddres if both fields exist:
db.vendors.updateMany(
  {
    locationAddres: { $exists: true },
    locationAddress: { $exists: true }
  },
  {
    $unset: { "locationAddres": "" }
  }
)
```

## Verification

After running the migration:

1. Check a few vendor records in MongoDB Compass
2. Restart the app: `flutter run`
3. Verify addresses display correctly on all vendor cards
4. Check that distances show "Unknown" for vendors without addresses

## Notes

- The Flutter app now handles both field names as a fallback
- This migration permanently fixes the database
- No data will be lost - addresses are just renamed
- The migration is idempotent (safe to run multiple times)
