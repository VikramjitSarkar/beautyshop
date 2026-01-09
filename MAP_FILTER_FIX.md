# Map Filter Functionality Fix

## Issues Fixed

### 1. **Filter State Not Syncing Between Bottom Sheet and Parent Widget**
- **Problem**: Filter changes in the bottom sheet (switches, sliders, buttons) only updated the bottom sheet's local state, not the parent widget's state
- **Solution**: Added `this.setState()` calls to update the parent `_MapScreenState` in addition to the bottom sheet's `setState()`

### 2. **Incorrect Field Name Mappings**
- **Problem**: Filter logic was checking for `vendor['homeVisit']` and `vendor['hasSalon']` which don't exist in the data structure
- **Actual Fields**: `homeServiceAvailable` (boolean) and `hasPhysicalShop` (boolean)
- **Solution**: Updated `applyLocalFilters()` to check the correct fields:
  ```dart
  final itemHomeVisit = vendor['homeServiceAvailable'] == true;
  final itemHasSalon = vendor['hasPhysicalShop'] == true;
  ```

### 3. **Price Range Filter Not Working**
- **Problem**: Was checking `vendor['charges']` but charges exist per service, not per vendor
- **Solution**: Iterate through all vendor services and find the minimum charge:
  ```dart
  final services = vendor['services'] as List<dynamic>?;
  int minServiceCharge = 999999;
  if (services != null && services.isNotEmpty) {
    for (var service in services) {
      final charges = int.tryParse(service['charges']?.toString() ?? '0') ?? 0;
      if (charges > 0 && charges < minServiceCharge) {
        minServiceCharge = charges;
      }
    }
  }
  ```

### 4. **Sort By Rating Using Wrong Field**
- **Problem**: `sortVendorsByRatingHighFirst()` was checking `vendor['shopRating']` which doesn't exist
- **Actual Field**: `avgRating`
- **Solution**: Changed to use the correct field name

### 5. **Sort By Distance Not Calculating Distance**
- **Problem**: Distance sorting relied on a `distance` field that may not exist in vendor data
- **Solution**: Calculate distance from current position if not present:
  ```dart
  if (vendor['distance'] == null && _currentPosition != null) {
    final lat = double.tryParse(vendor['vendorLat']?.toString() ?? '0');
    final lng = double.tryParse(vendor['vendorLong']?.toString() ?? '0');
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        lat,
        lng,
      ) / 1000; // Convert to km
      vendor['distance'] = distance;
    }
  }
  ```

### 6. **Sort Order Was Reversed**
- **Problem**: Distance sorting comment said "far → near" but should be "near → far"
- **Solution**: Fixed sorting to properly show nearest vendors first

## How Filters Work Now

### Filter Options:
1. **Sort By**:
   - **Near by**: Sorts vendors by distance (closest first)
   - **Popular**: Sorts vendors by rating (highest first)
   - **Rating**: Sorts vendors by rating (highest first)

2. **Online Now**: Shows only vendors with `status: "online"`

3. **Home Visit Available**: Shows only vendors with `homeServiceAvailable: true`

4. **Has Salon/Location**: Shows only vendors with `hasPhysicalShop: true`

5. **Price Range**: Filters vendors by minimum service charge ($0-$500)

### Filter Logic Flow:
1. User selects filter options in bottom sheet
2. State updates in both bottom sheet and parent widget
3. Clicks "Apply Filters"
4. `applyLocalFilters()` filters the vendor list based on all criteria
5. Sorting is applied based on `activeButtonIndex`
6. Filtered and sorted vendors update the map markers

### Reset Functionality:
- Resets all filter values to defaults
- Calls `_fetchNearbyVendors()` to reload all vendors from backend
- Closes bottom sheet

## Testing Checklist
- ✅ Sort by Near by - shows closest vendors first
- ✅ Sort by Popular/Rating - shows highest rated vendors first
- ✅ Online Now filter - only shows online vendors
- ✅ Home Visit Available - only shows vendors with home service
- ✅ Has Salon/Location - only shows vendors with physical location
- ✅ Price Range - filters by minimum service charge
- ✅ Combined filters work together
- ✅ Reset clears all filters and reloads vendors
- ✅ Filter state persists while bottom sheet is open

## Data Structure Reference

### Vendor Object Fields Used:
```dart
{
  "_id": "vendor_id",
  "status": "online" | "offline",
  "homeServiceAvailable": true | false,
  "hasPhysicalShop": true | false,
  "avgRating": 4.5,
  "vendorLat": "latitude_string",
  "vendorLong": "longitude_string",
  "services": [
    {
      "charges": "price_string",
      "subcategoryId": { "_id": "subcategory_id" }
    }
  ],
  "distance": calculated_distance_km  // May not exist, calculated if needed
}
```
