# TheBeautyShop Server Configuration Analysis
**Date:** December 19, 2025  
**Server IP:** 69.62.72.155

---

## 🔐 Server Credentials
- **IP Address:** 69.62.72.155
- **SSH Access:** `ssh root@69.62.72.155`
- **Password:** Angelraz@980
- **Control Panel:** https://69.62.72.155:34651/a976cc14
- **Additional Credentials:** x9uvvzyt / 6b25e26f

---

## 🌐 API Configuration

### Base URL
```
https://api.thebeautyshop.io
```
**Location:** `lib/constants/globals.dart`

### API Endpoints Used
1. **Authentication**
   - `/verify/send-otp` - Send OTP
   - `/verify/check-otp` - Verify OTP

2. **Vendor Management**
   - `/vendor/register` - Vendor registration
   - `/vendor/update` - Update vendor profile/gallery
   - `/vendor/byVendorId/{id}` - Get vendor by ID
   - `/vendor/search` - Search vendors
   - `/vendor/nearby` - Find nearby vendors

3. **Plans & Subscriptions**
   - `/plans/getAll` - Get all subscription plans
   - `/subscription` - Manage subscriptions

---

## 🔥 Firebase Configuration

### Project Details
- **Project ID:** beautician-50d49
- **Project Number:** 916801022458
- **Storage Bucket:** beautician-50d49.firebasestorage.app

### Android Configuration
- **App ID:** 1:916801022458:android:200c499718cbfd334b9c43
- **API Key:** AIzaSyCUNMGI0DR9qq_FtdewSk5W8uMbjmwcmfk
- **Package Name:** com.beautician.beautician_app

### iOS Configuration
- **App ID:** 1:916801022458:ios:8f06c5b5fe2ad8db4b9c43
- **API Key:** AIzaSyDaxvzJBs-Xk4qFKVi4a4NgkgICg3ZqFDs
- **Bundle ID:** com.beautician.beauticianApp

### Web Configuration
- **App ID:** 1:916801022458:web:12c6473c71c094bb4b9c43
- **API Key:** AIzaSyDw8u4i8maulM9CIFNyu-jgj_UMHxB8aRE
- **Auth Domain:** beautician-50d49.firebaseapp.com
- **Measurement ID:** G-7RC9ZZYJB7

### Firebase Services Enabled
✅ Firebase Core  
✅ Cloud Firestore (Database)  
✅ Firebase Realtime Database  
✅ Firebase Cloud Messaging (Push Notifications)  
✅ Firebase Storage (beautician-50d49.firebasestorage.app)

---

## 🔌 WebSocket Configuration

### Socket.IO Connection
- **URL:** `https://api.thebeautyshop.io`
- **Transport:** WebSocket only
- **Auto-connect:** Disabled (manual connection)

### Socket Events
1. **Registration Events**
   - `register` - Register user/vendor with ID and type

2. **Booking Events**
   - `bookingActivated` - Real-time booking activation
   - `bookingCompleted` - Real-time booking completion

3. **Chat Events**
   - Used for real-time messaging between users and vendors

**Implementation:** `lib/controllers/vendors/booking/qrCodeController.dart`

---

## 📦 Media Storage & Upload

### Upload Method
- **Type:** Multipart Form Data
- **Library:** http package (^1.3.0)

### Supported Media Types
1. **Images:**
   - Content-Type: `image/jpeg`
   - Used for: Profile images, shop banners, gallery photos, IDs, certifications

2. **Videos:**
   - Content-Type: `video/mp4`
   - Used for: Gallery videos
   - Supported formats: .mp4, .mov, .avi

### Gallery Upload Limits
- **Max files per upload:** 5 files
- **Endpoint:** `PUT /vendor/update`
- **Field name:** `gallery`

### Upload Endpoints
1. **Vendor Registration:** `POST /vendor/register`
   - Fields: profileImage, userName, email, password, phone, location, shopName, etc.

2. **Vendor Profile Update:** `PUT /vendor/update`
   - Fields: gallery, shopBanner, profileImage

3. **User Profile Update:** `PUT /user/update/{userId}`
   - Fields: profileImage

### Authentication
All upload requests use Bearer token authentication:
```
Authorization: Bearer {token}
```

---

## 🗄️ Database Structure

### Local Storage (SharedPreferences)
Stores:
- `token` - User authentication token
- `vendorLoginToken` - Vendor authentication token
- `vendorId` - Vendor ID
- `userId` - User ID
- `bookingId` - Current booking ID
- `vendorBookingId` - Vendor-side booking ID
- `vendorPaymentId` - Payment ID

### Firebase Services
1. **Cloud Firestore** - Structured data storage
2. **Realtime Database** - Real-time data synchronization
3. **Firebase Storage** - Media file storage

---

## 💳 Payment Integration

### Stripe Configuration
- **Publishable Key:** pk_test_LdzVjLW3uAsxkVjgF6WdjnXW00p4ufOVAO
- **API Endpoints:**
  - `https://api.stripe.com/v1/customers` - Create customer
  - `https://api.stripe.com/v1/payment_intents` - Create/retrieve payment intent

**Note:** Currently using test mode keys

---

## 📍 Location Services

### Geolocator
- **Package:** geolocator ^13.0.3
- **Features:**
  - Get current user location
  - Location permission handling
  - Nearby vendor search based on coordinates

### Geocoding
- **Package:** geocoding
- **Features:**
  - Convert addresses to latitude/longitude
  - Used during vendor registration

### Maps Integration
- **Google Maps Flutter:** ^2.12.1
- **Features:**
  - Display vendor locations
  - Navigation to vendors
  - Search vendors on map

---

## 🔔 Push Notifications

### Configuration
- **Service:** Firebase Cloud Messaging (FCM)
- **Channel ID:** high_importance_channel
- **Channel Name:** High Importance Notifications

### Implementation
- **Local Notifications:** flutter_local_notifications ^19.1.0
- **Foreground handling:** ✅ Enabled
- **Background handling:** ✅ Enabled
- **Notification icon:** @mipmap/ic_launcher

### Token Management
- FCM tokens are collected during initialization
- Sent to backend during registration
- Stored with user/vendor profile

---

## 🔒 Security Considerations

### ⚠️ ISSUES FOUND:

1. **Exposed API Keys in Code**
   - Firebase API keys are hardcoded in `firebase_options.dart`
   - Stripe test key is in `main.dart`
   - **Recommendation:** Use environment variables or secure key management

2. **No .env File**
   - Server credentials should be in environment files
   - **Recommendation:** Create .env file and add to .gitignore

3. **Test Stripe Keys in Production Code**
   - Still using test mode Stripe keys
   - **Recommendation:** Switch to production keys for live app

4. **Root SSH Access**
   - Using root user for SSH
   - **Recommendation:** Create non-root user with sudo privileges

---

## 📱 Dependencies Overview

### Core Dependencies
```yaml
http: ^1.3.0                    # API requests
socket_io_client: ^3.1.1        # Real-time communication
shared_preferences: ^2.5.3       # Local storage
```

### Firebase
```yaml
firebase_core: ^3.13.0
cloud_firestore: ^5.6.6
firebase_database: ^11.3.5
firebase_messaging: ^15.2.5
```

### Media & Files
```yaml
image_picker: ^1.1.2
file_picker: ^10.1.2
video_thumbnail: ^0.5.6
video_player: ^2.9.5
camera: ^0.11.1
image: ^4.5.4
```

### Location
```yaml
geolocator: ^13.0.3
geocoding: (latest)
google_maps_flutter: ^2.12.1
```

### UI & Utilities
```yaml
get: ^4.7.2                     # State management
responsive_sizer: ^3.3.1        # Responsive design
flutter_stripe: ^11.5.0         # Payment processing
```

---

## 🚀 Server Requirements Checklist

### Backend Server (69.62.72.155)
- [ ] Node.js/Express server running on port 443 (HTTPS)
- [ ] SSL certificate installed for api.thebeautyshop.io
- [ ] Socket.IO server configured
- [ ] File upload handling (multipart/form-data)
- [ ] MongoDB or similar database
- [ ] API endpoints as listed above implemented
- [ ] CORS configured for mobile app requests
- [ ] JWT token authentication
- [ ] FCM admin SDK configured for push notifications

### Database
- [ ] User collection/table
- [ ] Vendor collection/table
- [ ] Booking collection/table
- [ ] Chat/Message collection/table
- [ ] Plans/Subscription collection/table
- [ ] Payment records

### Storage
- [ ] File storage system for uploads (local or cloud)
- [ ] Image optimization/resizing pipeline
- [ ] Video thumbnail generation
- [ ] Backup strategy for media files

---

## 🔍 Recommended Actions

### Immediate Actions
1. **Verify SSL Certificate**
   - Check if https://api.thebeautyshop.io has valid SSL
   - Renew if expiring soon

2. **Test API Endpoints**
   ```bash
   curl -X GET https://api.thebeautyshop.io/plans/getAll
   ```

3. **Check Server Status**
   ```bash
   ssh root@69.62.72.155
   systemctl status <your-app-service>
   pm2 status  # if using PM2
   ```

4. **Database Backup**
   - Verify automatic backups are configured
   - Test restore procedure

5. **Monitor Logs**
   - Check application logs for errors
   - Monitor nginx/apache access logs
   - Review database query logs

### Security Improvements
1. Create .env file for sensitive data
2. Implement rate limiting on API endpoints
3. Add request validation and sanitization
4. Set up monitoring and alerts
5. Regular security audits
6. Update dependencies regularly

### Performance Optimization
1. Enable CDN for media files
2. Implement caching strategy
3. Optimize database queries with indexes
4. Set up load balancing if needed
5. Monitor server resources (CPU, RAM, Disk)

---

## 📞 Support & Documentation

### Key Files to Review
- `/lib/constants/globals.dart` - API configuration
- `/lib/firebase_options.dart` - Firebase setup
- `/lib/screens/firebaseServices.dart` - Push notifications
- `/lib/controllers/vendors/booking/qrCodeController.dart` - Socket.IO

### Testing Checklist
- [ ] User registration and login
- [ ] Vendor registration with image upload
- [ ] Gallery upload (images and videos)
- [ ] Real-time booking notifications
- [ ] Chat messaging
- [ ] Push notifications
- [ ] Location-based vendor search
- [ ] Payment processing
- [ ] Map integration

---

**Last Updated:** December 19, 2025  
**Analyzed By:** GitHub Copilot
