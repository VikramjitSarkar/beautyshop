# Backend API Fixes Required

## 🔴 CRITICAL ISSUES FOUND

### 1. Missing `/vendor/search` Endpoint
**Error:** Flutter app calls `POST /vendor/search` but it doesn't exist
**Fix:** Add search function to vendor controller

### 2. Wrong Route Name for Nearby Vendors
**Current:** `/vendor/nearBy` (capital B)
**Expected:** `/vendor/nearby` (all lowercase)
**Fix:** Change route definition

---

## 📝 FIX INSTRUCTIONS

### Step 1: Add Search Function to Vendor Controller

SSH into server:
```bash
ssh root@69.62.72.155
cd /www/wwwroot/api.thebeautyshop.io/salon-backend/controller
nano vendorController.js
```

**Add this function at the end of the file (before the last closing brace):**

```javascript
// Search vendors by query
export const searchVendors = async (req, res, next) => {
  try {
    const { query, latitude, longitude } = req.body;

    if (!query) {
      return res.status(400).json({ 
        status: "error", 
        message: "Search query is required" 
      });
    }

    // Build search filter
    const searchFilter = {
      $or: [
        { shopName: { $regex: query, $options: "i" } },
        { description: { $regex: query, $options: "i" } },
        { title: { $regex: query, $options: "i" } }
      ]
    };

    let vendors = await Vendor.find(searchFilter)
      .select('profileImage shopName shopBanner vendorLat vendorLong description title locationAddres')
      .limit(50);

    // If location provided, add distance
    if (latitude && longitude) {
      const calculateDistance = (lat1, lon1, lat2, lon2) => {
        const toRad = (value) => (value * Math.PI) / 180;
        const R = 6371;
        const dLat = toRad(lat2 - lat1);
        const dLon = toRad(lon2 - lon1);
        const a =
          Math.sin(dLat / 2) ** 2 +
          Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
      };

      vendors = vendors.map(vendor => {
        const vendorObj = vendor.toObject();
        if (vendorObj.vendorLat && vendorObj.vendorLong) {
          vendorObj.distance = calculateDistance(
            parseFloat(latitude),
            parseFloat(longitude),
            parseFloat(vendorObj.vendorLat),
            parseFloat(vendorObj.vendorLong)
          ).toFixed(2);
        }
        return vendorObj;
      });

      // Sort by distance
      vendors.sort((a, b) => (a.distance || 999) - (b.distance || 999));
    }

    res.status(200).json({
      status: "success",
      data: vendors,
      count: vendors.length
    });
  } catch (error) {
    console.error("Search vendors error:", error);
    res.status(500).json({ 
      status: "error", 
      message: "Failed to search vendors" 
    });
  }
};
```

**Save and exit** (Ctrl+X, Y, Enter)

---

### Step 2: Update Vendor Routes

```bash
cd /www/wwwroot/api.thebeautyshop.io/salon-backend/routes
nano vendorRoute.js
```

**Replace the import section at the top:**

```javascript
import {
  registerVendor,
  loginVendor,
  getAllVendor,
  getVendorById,
  deleteVendorById,
  UpdateProfile,
  UpdateStatus,
  ProfileSetup,
  getVendorById2,
  getNearbyVendors,
  searchVendors,  // <-- ADD THIS LINE
} from "../controller/vendorController.js";
```

**Then find this line:**
```javascript
vendorRoute.route("/nearBy").post(getNearbyVendors);
```

**Replace it with these two lines:**
```javascript
vendorRoute.route("/nearby").post(getNearbyVendors);  // Changed to lowercase
vendorRoute.route("/search").post(searchVendors);     // NEW - Added search endpoint
```

**Save and exit** (Ctrl+X, Y, Enter)

---

### Step 3: Restart PM2

```bash
pm2 restart beautyshop-api
pm2 logs beautyshop-api --lines 20
```

---

## ✅ VERIFICATION

After making changes, test these endpoints:

### 1. Test Vendor Search
```bash
curl -X POST https://api.thebeautyshop.io/vendor/search \
  -H "Content-Type: application/json" \
  -d '{"query":"salon"}'
```

### 2. Test Nearby Vendors (new lowercase route)
```bash
curl -X POST https://api.thebeautyshop.io/vendor/nearby \
  -H "Content-Type: application/json" \
  -d '{"userLat":40.7128,"userLong":-74.0060}'
```

---

## 📊 SUMMARY

**Issues Fixed:**
1. ✅ Added `/vendor/search` endpoint
2. ✅ Fixed `/vendor/nearBy` → `/vendor/nearby`

**Files Modified:**
- `/www/wwwroot/api.thebeautyshop.io/salon-backend/controller/vendorController.js`
- `/www/wwwroot/api.thebeautyshop.io/salon-backend/routes/vendorRoute.js`

**Restart Required:** Yes (`pm2 restart beautyshop-api`)

---

## 🔧 ADDITIONAL RECOMMENDATIONS

### Database Indexes for Better Performance

```bash
mongo
use Cluster0  # or your database name
db.vendors.createIndex({ shopName: "text", description: "text", title: "text" })
db.vendors.createIndex({ vendorLat: 1, vendorLong: 1 })
```

This will make search and nearby queries much faster.

---

**Ready to implement? Run the commands above on your server!**
