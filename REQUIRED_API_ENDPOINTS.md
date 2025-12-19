# Complete API Endpoints Used by Your Flutter App

Based on your Flutter code, here are ALL the endpoints your backend MUST implement:

## ✅ WORKING ENDPOINTS (Confirmed)
1. `GET /plans/getAll` - Get all subscription plans

## 🔴 ENDPOINTS THAT NEED TO BE IMPLEMENTED/FIXED

### Authentication & User Management
```
POST /user/register - User registration
POST /user/login - User login  
POST /user/auth/forgot-password - Forgot password
POST /user/auth/password - Reset password
GET /user/get - Get user profile (requires auth token)
PUT /user/update - Update user profile (requires auth token)
POST /verify/send-otp - Send OTP for verification
POST /verify/check-otp - Verify OTP
```

### Vendor Management
```
POST /vendor/register - Vendor registration
POST /vendor/login - Vendor login
GET /vendor/get - Get vendor profile (requires auth token)
GET /vendor/getAll - Get all vendors
GET /vendor/byVendorId/:id - Get vendor by ID
PUT /vendor/update - Update vendor profile
PUT /vendor/profileSetup - Complete vendor profile setup
POST /vendor/search - Search vendors (with query parameter)
POST /vendor/nearby - Find nearby vendors (lat/long)
```

### Categories & Subcategories
```
GET /category/getAll - Get all categories
GET /category/userDashboard - Get categories for user dashboard
GET /subcategory/getAll - Get all subcategories
GET /subcategory/getbyCategoryId/:id - Get subcategories by category
POST /subcategory/nearbySubcategory - Find nearby subcategories
```

### Services
```
GET /service/getAll - Get all services
GET /service/byVendorId/:id - Get services by vendor
POST /service/create - Create new service
PUT /service/update/:id - Update service
```

### Bookings
```
POST /booking/create - Create new booking
GET /booking/user?status=:status - Get user bookings by status (pending/accept/past)
GET /booking/vendor/:id?status=:status - Get vendor bookings
PUT /booking/update/:id - Update booking
PUT /booking/accept/:id - Accept booking
PUT /booking/reject/:id - Reject booking
PUT /booking/reschedule/:id - Reschedule booking
DELETE /booking/delete/:id - Delete booking
```

### Reviews
```
GET /review/vendor/:id - Get reviews for a vendor
POST /review/create - Create a review
```

### Chat/Messaging
```
GET /chat/allChats/:userId - Get all chats for user
GET /chat/allMessages/:chatId - Get messages in a chat
POST /chat/create - Create new chat
POST /chat/message - Send message
```

### Notifications
```
GET /notification/forUser/:id - Get notifications for user
GET /notification/forVendor/:id - Get notifications for vendor
```

### Subscriptions
```
POST /subscription - Create subscription
GET /subscription/:id - Get subscription details
```

### Referrals
```
POST /referral/redeem - Redeem referral code
```

---

## 🔧 REQUIRED DATABASE COLLECTIONS

Based on the API endpoints, your MongoDB needs these collections:

### 1. users
```javascript
{
  _id: ObjectId,
  userName: String,
  email: String,
  password: String (hashed),
  phone: String,
  profileImage: String (URL),
  locationAdress: String, // Note typo: "Adress"
  userLat: Number,
  userLong: Number,
  gender: String,
  dateofBirth: String,
  profession: String,
  favoriteVendors: [ObjectId],
  fcmToken: String,
  createdAt: Date,
  updatedAt: Date
}
```

### 2. vendors
```javascript
{
  _id: ObjectId,
  userName: String,
  email: String,
  password: String (hashed),
  phone: String,
  profileImage: String (URL),
  shopBanner: String (URL),
  shopName: String,
  title: String,
  description: String,
  locationAddres: String,
  vendorLat: Number,
  vendorLong: Number,
  gallery: [String], // Array of image/video URLs
  listingPlan: String,
  homeServiceAvailable: Boolean,
  isActive: Boolean,
  status: String,
  fcmToken: String,
  subscriptionId: ObjectId,
  createdAt: Date,
  updatedAt: Date
}
```

### 3. categories
```javascript
{
  _id: ObjectId,
  name: String,
  image: String,
  createdAt: Date
}
```

### 4. subcategories
```javascript
{
  _id: ObjectId,
  name: String,
  categoryId: ObjectId,
  image: String,
  createdAt: Date
}
```

### 5. services
```javascript
{
  _id: ObjectId,
  vendorId: ObjectId,
  categoryId: ObjectId,
  subcategoryId: ObjectId,
  name: String,
  description: String,
  price: Number,
  duration: Number,
  createdAt: Date
}
```

### 6. bookings
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  vendorId: ObjectId,
  services: [ObjectId],
  date: Date,
  time: String,
  status: String, // 'pending', 'accept', 'past', 'reject'
  totalAmount: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### 7. reviews
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  vendorId: ObjectId,
  rating: Number,
  description: String,
  location: String,
  createdAt: Date
}
```

### 8. chats
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  vendorId: ObjectId,
  messages: [{
    senderId: ObjectId,
    senderType: String, // 'user' or 'vendor'
    message: String,
    timestamp: Date
  }],
  createdAt: Date
}
```

### 9. notifications
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  vendorId: ObjectId,
  type: String,
  message: String,
  read: Boolean,
  createdAt: Date
}
```

### 10. plans (Already exists ✅)
```javascript
{
  _id: ObjectId,
  price: Number,
  durationInDays: Number
}
```

### 11. subscriptions
```javascript
{
  _id: ObjectId,
  vendorId: ObjectId,
  planId: ObjectId,
  startDate: Date,
  endDate: Date,
  status: String, // 'active', 'expired'
  paymentId: String,
  createdAt: Date
}
```

### 12. referrals
```javascript
{
  _id: ObjectId,
  code: String,
  vendorId: ObjectId,
  usedBy: [ObjectId],
  discount: Number,
  createdAt: Date
}
```

---

## 📝 NEXT STEPS

Please SSH into your server and share:

1. **Application directory location:**
```bash
find /var/www /opt /home -name "package.json" -not -path "*/node_modules/*" 2>/dev/null
```

2. **Current routes file:**
```bash
# Find your routes file
find /path/to/app -name "*route*" -o -name "*api*" | grep -v node_modules

# Show current routes
cat /path/to/app/routes/api.js  # or whatever your routes file is named
```

3. **Current database collections:**
```bash
mongo beautician --quiet --eval "db.getCollectionNames()"
```

Once you provide this, I can give you the EXACT code to add missing endpoints and database schemas.
