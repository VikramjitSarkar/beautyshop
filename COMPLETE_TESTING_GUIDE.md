# Complete Testing Guide - Beauty Shop App

## Testing Date: January 6, 2026
## App Version: Latest Build

---

## TABLE OF CONTENTS
1. [User Authentication Flow](#user-authentication-flow)
2. [User Navigation & Screens](#user-navigation--screens)
3. [Vendor Navigation & Screens](#vendor-navigation--screens)
4. [Booking Flow Testing](#booking-flow-testing)
5. [Payment Flow Testing](#payment-flow-testing)
6. [Review & Rating Testing](#review--rating-testing)
7. [Filter & Search Testing](#filter--search-testing)
8. [Chat & Communication Testing](#chat--communication-testing)
9. [Profile & Settings Testing](#profile--settings-testing)
10. [Edge Cases & Error Handling](#edge-cases--error-handling)

---

## 1. USER AUTHENTICATION FLOW

### 1.1 Onboarding Screens
**Location:** `lib/views/onboarding/`

#### Test Steps:
1. **Launch App**
   - Screen: `onboardingScreen.dart`
   - Elements to Test:
     - Swipe through onboarding slides (3-4 slides)
     - Skip button (top right)
     - Next button (bottom)
     - Get Started button (last slide)
   
2. **Role Selection Screen**
   - Screen: `roleSelectionScreen.dart`
   - Tap: "I'm a User" button
   - Tap: "I'm a Vendor" button
   - Verify navigation to respective signup flows

### 1.2 User Registration Flow
**Location:** `lib/views/user/authentication/`

#### Test Steps:
1. **Signup Screen** (`signup_screen.dart`)
   - Fields:
     - Full Name (text input)
     - Email (text input)
     - Phone Number (text input)
     - Password (text input with visibility toggle)
     - Confirm Password (text input with visibility toggle)
   - Tap: Eye icon to show/hide password
   - Tap: "Sign Up" button
   - Tap: "Already have account? Login" link
   - Verify: Email validation
   - Verify: Phone number format validation
   - Verify: Password match validation

2. **OTP Verification Screen** (`otp_screen.dart`)
   - Elements:
     - 6 OTP input boxes
     - Resend OTP button
     - Timer countdown
     - Verify button
   - Test: Enter valid OTP
   - Test: Resend OTP after timer
   - Test: Invalid OTP handling

3. **Login Screen** (`login_screen.dart`)
   - Fields:
     - Email/Phone (text input)
     - Password (text input with visibility toggle)
   - Tap: Eye icon to show/hide password
   - Tap: "Login" button
   - Tap: "Forgot Password?" link
   - Tap: "Don't have account? Sign Up" link
   - Test: Remember Me checkbox

4. **Forgot Password Flow** (`forgot_password_screen.dart`)
   - Enter email/phone
   - Tap: "Send Reset Link" button
   - Enter OTP
   - Set new password
   - Confirm password
   - Submit

---

## 2. USER NAVIGATION & SCREENS

### 2.1 Bottom Navigation Bar (User)
**Location:** `lib/views/user/nav_bar_screens/custom_nav_bar.dart`

#### 5 Main Tabs:
1. **Home Tab** (Index 0)
2. **Map Tab** (Index 1)
3. **Booking Tab** (Index 2)
4. **Wishlist Tab** (Index 3)
5. **Profile Tab** (Index 4)

---

### 2.2 HOME TAB - Detailed Testing

**Main Screen:** `lib/views/user/nav_bar_screens/home/user_home_screen.dart`

#### Elements to Test:

1. **Top App Bar**
   - Location icon with city name (tap to change location)
   - Notification bell icon (tap to view notifications)
   - Profile avatar (tap to go to profile)

2. **Search Bar**
   - Tap: Search icon → Navigate to `search_screen.dart`
   - Enter search query
   - View search results

3. **Banner/Carousel Slider**
   - Auto-scroll promotional banners
   - Swipe left/right manually
   - Tap banner to view details

4. **Category Grid**
   - Display all service categories (Hair, Makeup, Spa, etc.)
   - Tap category card → Navigate to `salon_list_screen.dart`
   - Each card shows:
     - Category icon
     - Category name
     - Vendor count

5. **"Near You" Section**
   - Horizontal scrollable list of nearby salons
   - Each card shows:
     - Salon image
     - Salon name
     - Rating (stars)
     - Distance
     - Price range
   - Tap card → Navigate to `salon_detail_page.dart`

6. **"Top Rated" Section**
   - Horizontal scrollable list of top-rated salons
   - Same card layout as "Near You"
   - Tap "See All" → Navigate to filtered `salon_list_screen.dart`

7. **"Featured Salons" Section**
   - Grid/list of featured vendors
   - Premium badge indicator
   - Tap to view details

---

### 2.3 MAP TAB - Detailed Testing

**Main Screen:** `lib/views/user/nav_bar_screens/map/map_screen.dart`

#### Elements to Test:

1. **Google Maps View**
   - Map loads with user's current location
   - Blue dot shows user location
   - Zoom in/out with pinch gesture
   - Pan around the map
   - Custom markers for salons

2. **Top Search Bar**
   - Search field with category dropdown
   - Tap search → Filter vendors on map
   - Current location button (GPS icon)

3. **Category Chips (Horizontal Scroll)**
   - All categories as chips
   - Tap chip to filter map markers
   - Active chip highlighted in primary color

4. **Filter Button** (Funnel icon)
   - Tap → Show filter bottom sheet
   - **Filter Bottom Sheet Elements:**
     - "Sort by" section:
       - Distance button
       - Popular button
       - Newest button
       - Rating button
     - "Online Now" switch
     - "Home Visit Available" switch
     - "Has Salon/Location" switch
     - "Nearby" switch
     - Price Range slider (₹0 - ₹1000)
     - Reset button
     - Apply Filters button
   - Verify: Bottom sheet doesn't go behind navigation bar (SafeArea fix)

5. **Salon Markers on Map**
   - Custom markers for each salon
   - Tap marker → Show info window with salon name
   - Tap info window → Show bottom card details

6. **Bottom Salon Cards (Swipeable)**
   - Horizontal PageView of nearby salons
   - Each card shows:
     - Salon image
     - Salon name
     - Rating (fetch from `avgRating`, not hardcoded 0.0)
     - Distance
     - Category
     - "View Details" button
   - Swipe left/right to browse
   - Tap card → Navigate to `salon_detail_page.dart`

7. **Three Tabs (Top of Screen)**
   - **All Tab** (`all_tab_screen.dart`)
     - Shows all vendors
     - Has its own filter button
   - **Open Now Tab** (`open_now_tab_screen.dart`)
     - Shows only currently open vendors
     - Has its own filter button
   - **Nearest Tab** (`nearest_tab_screen.dart`)
     - Shows vendors sorted by distance
     - Has its own filter button

---

### 2.4 BOOKING TAB - Detailed Testing

**Main Screen:** `lib/views/user/nav_bar_screens/appointment/appointment_screen.dart`

#### Three Sub-Tabs:

1. **Pending Bookings Tab** (`pending_booking.dart`)
   
   **Card Elements:**
   - Vendor name
   - Booking date & time
   - Service name
   - Service price
   - Status badge: "Pending"
   - "View Details" button
   
   **Tap "View Details" → Dialog Box:**
   - Vendor info (name, location)
   - Service details
   - Price breakdown
   - Date & time
   - Payment status
   - **User's Review Display** (if given before):
     - Star rating (5-star emoji system: 😡🙁🙂😃🤩)
     - Review comment
     - Review date
   - "Cancel Booking" button
   - "Contact Vendor" button
   - Close button (X)

2. **Upcoming Bookings Tab** (`upcoming_tab_screen.dart`)
   
   **Card Elements:**
   - Same as Pending tab
   - Status badge: "Confirmed" or "Upcoming"
   
   **Tap "View Details" → Dialog Box:**
   - All details same as Pending
   - **User's Review Display** (if given)
   - "Cancel Booking" button (if allowed)
   - "Reschedule" button
   - "Get Directions" button
   - "Contact Vendor" button

3. **Past Bookings Tab** (`past_tab_screen.dart`)
   
   **Card Elements:**
   - Same layout as other tabs
   - Status badge: "Completed" or "Cancelled"
   
   **Tap "View Details" → Dialog Box:**
   - Booking details (read-only)
   - **User's Review Display** (if already given):
     - Shows rating stars
     - Shows review comment
     - Shows review date
   - "Write Review" button (if not reviewed yet)
   - "Book Again" button
   - Download invoice button

---

### 2.5 SALON DETAIL PAGE - Detailed Testing

**Screen:** `lib/views/user/nav_bar_screens/home/salon_detail_page.dart`

#### Top App Bar
**File:** `lib/views/user/nav_bar_screens/home/salon_detail_page_appbar.dart`
- Back button (Icon with green circular background, black icon)
- Share button (Icon with green circular background, black icon)
- Background: App green color
- Body wrapped in `SafeArea(bottom: true)` to prevent content going behind nav bar

#### Elements to Test:

1. **Salon Header Section**
   - Large salon cover image
   - Salon name
   - Rating stars with count (e.g., 4.5 ⭐ 234 reviews)
   - Category badges
   - Favorite/Wishlist heart icon (tap to add/remove)

2. **Contact Bar**
   - Call icon → Dial salon number
   - Message icon → Open chat
   - Location icon → Open maps
   - Share icon → Share salon details

3. **Tab Bar (Scrollable)**
   - **Services Tab**
     - List of all services
     - Each service card:
       - Service name
       - Duration
       - Price
       - Add to cart button (+)
   
   - **About Tab**
     - Salon description
     - Opening hours
     - Amenities/Facilities icons
     - Policies
   
   - **Gallery Tab**
     - Grid of salon images
     - Tap image → Full screen view
     - Swipe through gallery
   
   - **Reviews Tab**
     - List of customer reviews
     - Each review shows:
       - Customer name & avatar
       - Star rating
       - Review text
       - Date
       - Helpful count
     - "Write Review" button (if user has booking)

4. **Floating Action Button / Bottom Bar**
   - "View Cart" button (if items added)
   - "Book Now" button
   - Wrapped in `SafeArea` to prevent going behind system nav bar

---

### 2.6 SERVICE BOOKING FLOW

**Screen:** `lib/views/user/services/salon_services_card.dart`

#### Test Steps:

1. **Service Selection**
   - Browse services list
   - Tap service card to expand details
   - Tap "+" to add service to cart
   - Tap "-" to remove service
   - View cart icon with count badge

2. **Booking Details Screen** (`booking_details_screen.dart`)
   - Selected services list
   - Date picker (tap to select date)
   - Time slot selector (tap available slot)
   - Add note/special request field
   - Coupon code field
   - Price breakdown:
     - Service subtotal
     - Taxes
     - Discount (if coupon applied)
     - Total amount
   - "Continue to Payment" button
   - Bottom navigation wrapped in `SafeArea`

3. **Payment Screen** (`payment_screen.dart`)
   - Payment method selection:
     - Credit/Debit Card
     - UPI
     - Wallet
     - Pay at Venue
   - Card details form (if card selected)
   - "Pay Now" button
   - Terms & conditions checkbox

4. **Booking Confirmation**
   - Success animation/icon
   - Booking ID
   - Booking details summary
   - "View Booking" button
   - "Go to Home" button

---

### 2.7 WISHLIST TAB - Detailed Testing

**Screen:** `lib/views/user/nav_bar_screens/wishlist/wishlist_screen.dart`

#### Elements to Test:

1. **Wishlist Grid/List**
   - Shows all favorited salons
   - Each card:
     - Salon image
     - Salon name
     - Rating
     - Distance
     - Heart icon (filled, tap to remove)
   - Empty state if no favorites

2. **Actions**
   - Tap card → Navigate to salon detail page
   - Tap heart icon → Remove from wishlist with confirmation
   - Pull to refresh

---

### 2.8 PROFILE TAB - Detailed Testing

**Screen:** `lib/views/user/nav_bar_screens/profile/user_profile_screen.dart`

#### Elements to Test:

1. **Profile Header**
   - User avatar/photo (tap to change)
   - User name
   - Email
   - Phone number
   - Edit profile button

2. **Menu Options (List Tiles)**
   
   **Personal Section:**
   - **Edit Profile** → `edit_profile_screen.dart`
     - Name field
     - Email field (may be readonly)
     - Phone field
     - Gender dropdown
     - Date of birth picker
     - Save button
   
   - **My Addresses** → `address_list_screen.dart`
     - List of saved addresses
     - Add new address button
     - Edit address
     - Delete address
     - Set default address
   
   - **Payment Methods** → `payment_methods_screen.dart`
     - Saved cards list
     - Add new card
     - Remove card
     - Set default payment method

   **Preferences:**
   - **Notifications Settings** → `notification_settings_screen.dart`
     - Push notifications toggle
     - Email notifications toggle
     - SMS notifications toggle
     - Booking reminders toggle
     - Promotional offers toggle
   
   - **Language & Region** → `language_screen.dart`
     - Language selector
     - Currency selector
     - Region selector

   **Support:**
   - **Help & Support** → `help_support_screen.dart`
     - FAQs
     - Contact support
     - Report issue
   
   - **Terms & Conditions** → WebView
   - **Privacy Policy** → WebView
   - **About Us** → WebView

   **Account:**
   - **Logout** → Confirmation dialog
   - **Delete Account** → Confirmation with password

---

### 2.9 SEARCH SCREEN - Detailed Testing

**Screen:** `lib/views/user/nav_bar_screens/search/search_screen.dart`

#### Elements to Test:

1. **Search Bar**
   - Text input field
   - Search icon
   - Clear text icon (X)
   - Voice search icon (if available)

2. **Recent Searches**
   - List of recent search queries
   - Tap to search again
   - Clear individual item
   - Clear all button

3. **Popular Searches / Trending**
   - Chip-style suggestions
   - Tap to search

4. **Search Results** (`search_card_screen.dart`)
   - Results display in list/grid
   - Each result card shows salon info
   - Filter button (top right)
   - **Filter Bottom Sheet:**
     - Same filters as map screen
     - Sort options: Distance, Popular, Newest, Rating
     - Online Now switch
     - Home Visit Available switch
     - Has Salon/Location switch
     - Price Range slider
     - Reset button
     - Apply Filters button
     - **Verify:** Bottom sheet doesn't go behind navigation bar
   
5. **No Results State**
   - Empty state illustration
   - "No results found" message
   - Suggestions for new search

---

### 2.10 NOTIFICATIONS SCREEN

**Screen:** `lib/views/user/nav_bar_screens/notifications/notifications_screen.dart`

#### Elements to Test:

1. **Notifications List**
   - Each notification card:
     - Icon (booking, offer, system)
     - Title
     - Message
     - Timestamp
     - Read/Unread indicator
   - Tap notification → Navigate to relevant screen
   - Swipe to dismiss
   - Mark as read
   - Mark all as read button
   - Delete notification

2. **Empty State**
   - "No notifications" illustration
   - Message text

---

## 3. VENDOR NAVIGATION & SCREENS

### 3.1 Bottom Navigation Bar (Vendor)
**Location:** `lib/views/vendor/vendor_nav_bar/bottom_nav_bar.dart`

#### 5 Main Tabs:
1. **Home Tab** (Index 0)
2. **Bookings Tab** (Index 1)
3. **Chat Tab** (Index 2)
4. **Services Tab** (Index 3)
5. **Profile Tab** (Index 4)

**Note:** Wrapped in `SafeArea` with margins to prevent going behind system navigation bar

---

### 3.2 VENDOR HOME TAB

**Screen:** `lib/views/vendor/home/vendor_home_screen.dart`

#### Elements to Test:

1. **Dashboard Cards**
   - Today's Bookings count
   - Pending Approvals count
   - Total Revenue (this month)
   - Ratings overview
   - Tap each card → Navigate to detailed view

2. **Quick Actions**
   - Add New Service
   - Update Schedule
   - View Reviews
   - Analytics

3. **Today's Schedule**
   - Timeline view of appointments
   - Each appointment shows:
     - Time
     - Customer name
     - Service
     - Status
   - Tap to view details

4. **Recent Reviews**
   - Latest customer reviews
   - Quick reply option

---

### 3.3 VENDOR BOOKINGS TAB

**Screen:** `lib/views/vendor/bookings/vendor_bookings_screen.dart`

#### Four Sub-Tabs:

1. **New Requests Tab**
   - Pending approval bookings
   - Accept button
   - Decline button
   - View customer details

2. **Upcoming Tab**
   - Confirmed appointments
   - Mark as started button
   - Mark as completed button
   - Reschedule option
   - Cancel option

3. **Completed Tab**
   - Past completed bookings
   - View payment details
   - Request review reminder

4. **Cancelled Tab**
   - Cancelled bookings history
   - Cancellation reason
   - Refund status

---

### 3.4 VENDOR CHAT TAB

**Screen:** `lib/views/vendor/chat/vendor_chat_screen.dart`

#### Elements to Test:

1. **Chat List**
   - Active conversations
   - Each chat item:
     - Customer avatar
     - Customer name
     - Last message preview
     - Timestamp
     - Unread count badge
   - Tap → Open chat conversation

2. **Chat Conversation Screen**
   - Message history
   - Text input field (wrapped in SafeArea)
   - Send button
   - Attachment icon
   - Image picker
   - Keyboard handling
   - Auto-scroll to latest message

---

### 3.5 VENDOR SERVICES TAB

**Screen:** `lib/views/vendor/services/vendor_services_screen.dart`

#### Elements to Test:

1. **Services List**
   - All vendor's services
   - Each service card:
     - Service name
     - Category
     - Duration
     - Price
     - Active/Inactive toggle
     - Edit button
     - Delete button

2. **Add Service Button** (FAB)
   - Tap → Navigate to add service form
   - Service name field
   - Category dropdown
   - Description field
   - Duration picker
   - Price field
   - Image upload
   - Save button

3. **Edit Service**
   - Pre-filled form
   - Update fields
   - Save changes
   - Cancel button

---

### 3.6 VENDOR PROFILE TAB

**Screen:** `lib/views/vendor/profile/vendor_profile_screen.dart`

#### Elements to Test:

1. **Shop Profile Header**
   - Shop logo/cover image
   - Shop name
   - Category
   - Rating
   - Edit button

2. **Menu Options**
   - **Shop Details** → Edit shop info
   - **Business Hours** → Set opening/closing times
   - **Gallery** → Manage shop images
   - **Bank Details** → Payment settings
   - **Reviews & Ratings** → View all reviews
   - **Analytics** → Performance metrics
   - **Subscription Plan** → Upgrade/manage plan
   - **Settings** → App preferences
   - **Help & Support**
   - **Logout**

---

## 4. BOOKING FLOW TESTING

### 4.1 Complete Booking Flow (User Side)

1. **Start:** Home screen
2. Tap category OR search for salon
3. View salon list
4. Tap salon card → Salon detail page
5. Navigate to Services tab
6. Select service(s) → Add to cart
7. Tap "Book Now"
8. Select date from calendar
9. Select time slot
10. Add special notes (optional)
11. Apply coupon (optional)
12. Review booking details
13. Tap "Continue to Payment"
14. Select payment method
15. Enter payment details
16. Tap "Pay Now"
17. Payment processing
18. Booking confirmation
19. Navigate to Bookings tab to verify

### 4.2 Booking Management (Vendor Side)

1. **Start:** Vendor home screen
2. New booking notification appears
3. Navigate to Bookings tab → New Requests
4. View booking details
5. **Accept Booking:**
   - Tap Accept
   - Confirmation dialog
   - Booking moves to Upcoming tab
6. **OR Decline Booking:**
   - Tap Decline
   - Enter reason
   - Confirm
7. **Mark as Started:**
   - In Upcoming tab
   - Tap Mark as Started
   - Customer notified
8. **Mark as Completed:**
   - Tap Mark as Completed
   - Confirm
   - Booking moves to Completed tab
   - Request customer review

---

## 5. PAYMENT FLOW TESTING

### 5.1 Payment Methods to Test

1. **Card Payment**
   - Enter card number (16 digits)
   - Expiry date (MM/YY)
   - CVV (3-4 digits)
   - Cardholder name
   - Verify 3D Secure
   - Success/failure handling

2. **UPI Payment**
   - Enter UPI ID
   - Verify with UPI app
   - Success/failure handling

3. **Wallet Payment**
   - Select wallet (Paytm, PhonePe, etc.)
   - Redirect to wallet app
   - Complete payment
   - Return to app

4. **Pay at Venue**
   - Select option
   - Booking confirmed
   - Payment pending status

### 5.2 Payment States

- Processing
- Success
- Failed
- Refund initiated
- Refund completed

---

## 6. REVIEW & RATING TESTING

### 6.1 Submit Review (User)

**Screen:** `lib/views/user/review/userReviewScreen.dart`

#### Test Steps:

1. Navigate to Past Bookings
2. Tap booking → "Write Review" button
3. **Review Form:**
   - Select star rating (1-5 stars)
   - **5 Emoji Options:**
     - 1 Star: 😡 (Terrible)
     - 2 Stars: 🙁 (Bad)
     - 3 Stars: 🙂 (Okay)
     - 4 Stars: 😃 (Good)
     - 5 Stars: 🤩 (Excellent)
   - Write review comment (optional)
   - Upload photos (optional)
   - Submit button
   - Wrapped in SafeArea to prevent going behind nav bar

4. Verify review appears in salon's review list
5. Check review display in booking details dialog

### 6.2 View Reviews (Vendor)

1. Navigate to Profile → Reviews & Ratings
2. View all customer reviews
3. Reply to reviews
4. Report inappropriate reviews
5. View average rating

---

## 7. FILTER & SEARCH TESTING

### 7.1 Filter Bottom Sheets (All 4 Locations)

#### Location 1: Map Screen Filter
**File:** `lib/views/user/nav_bar_screens/map/map_screen.dart` (line 1082)

**Test:**
- Tap filter icon on map screen
- Bottom sheet appears
- **Verify SafeArea:** Sheet doesn't go behind phone navigation bar
- Test all filter options:
  - Sort by: Distance, Popular, Newest, Rating (4 buttons)
  - Online Now switch
  - Home Visit Available switch
  - Has Salon/Location switch
  - Price Range slider (drag to adjust ₹0-₹1000)
- Tap Reset → All filters cleared
- Tap Apply → Filters applied, sheet closes
- Verify map updates with filtered results

#### Location 2: Base Tab Screen Filter
**File:** `lib/views/user/nav_bar_screens/map/tabs/base_tab_screen.dart` (line 244)

**Test:**
- Same as Map Screen Filter
- Verify works in All/Open Now/Nearest tabs
- Verify SafeArea implementation

#### Location 3: Search Card Screen Filter
**File:** `lib/views/user/nav_bar_screens/search/search_card_screen.dart` (line 579)

**Test:**
- Perform search
- Tap filter icon in search results
- Test all filter options
- Verify SafeArea preventing overlap
- Apply filters and verify results update

#### Location 4: Salon List Screen Filter
**File:** `lib/views/user/nav_bar_screens/home/salon_list_screen.dart` (line 663)

**Test:**
- Select category from home
- View salon list
- Tap filter icon
- Test all filter options
- Verify SafeArea implementation
- Apply and verify results

### 7.2 Filter Field Mappings (Critical)

**Verify these database field mappings work correctly:**
- `homeServiceAvailable` → Backend field for home visit service
- `hasPhysicalShop` → Backend field for salon location
- `avgRating` → Correct rating field (NOT hardcoded 0.0)
- Distance calculation → Uses user's current GPS location
- Price range → Filters by service prices

---

## 8. CHAT & COMMUNICATION TESTING

### 8.1 User Chat Screen
**File:** `lib/views/user/nav_bar_screens/chat/chat_user_screen.dart`

#### Test Steps:

1. Navigate to salon detail → Tap message icon
2. Chat screen opens
3. **Test Elements:**
   - Message history loads
   - Text input field (wrapped in SafeArea)
   - Send button
   - Type message → Tap send
   - Message appears in chat
   - Verify timestamp
   - Image attachment (tap camera icon)
   - Select/take photo
   - Send image
   - Verify image displays in chat

4. **Test SafeArea:**
   - Open keyboard
   - Verify input field doesn't go behind nav bar
   - Input field should be visible above keyboard

### 8.2 Vendor Chat Screen
**File:** `lib/views/vendor/chat/vendor_chat_screen.dart`

#### Test Steps:

1. Navigate to Bookings → Tap contact customer
2. OR from Chat tab → Tap conversation
3. **Test Elements:**
   - Same as user chat
   - Message input wrapped in SafeArea
   - Verify proper keyboard handling

---

## 9. PROFILE & SETTINGS TESTING

### 9.1 Edit Profile

**Test Fields:**
- Profile photo upload
- Name change
- Email (may be readonly)
- Phone number
- Gender selection
- Date of birth
- Bio/description
- Save changes button
- Cancel button

### 9.2 Address Management

**Test:**
- View saved addresses
- Add new address:
  - Address type (Home, Work, Other)
  - Street address
  - City
  - State
  - Pincode
  - Landmark
  - Location picker (map)
  - Set as default toggle
  - Save
- Edit existing address
- Delete address (with confirmation)
- Select address during booking

### 9.3 Notification Settings

**Test Toggles:**
- Push notifications master toggle
- Booking confirmations
- Booking reminders (1 hour before)
- Cancellation alerts
- Promotional offers
- New messages
- Email notifications
- SMS notifications

---

## 10. EDGE CASES & ERROR HANDLING

### 10.1 Network Issues

**Test:**
- Turn off internet
- Try to load screens → Show offline message
- Try to make booking → Error message
- Queue actions for retry when online
- Turn on internet → Auto-retry queued actions

### 10.2 GPS/Location Issues

**Test:**
- Deny location permission → Show rationale dialog
- Location services disabled → Prompt to enable
- No GPS signal → Show loading/waiting state
- Location timeout → Show error with retry button

### 10.3 Payment Failures

**Test:**
- Insufficient funds → Error message
- Card declined → Error message with support contact
- Network timeout during payment → Verify no double charge
- Payment gateway down → Show appropriate error

### 10.4 Invalid Data

**Test:**
- Empty form submission → Show validation errors
- Invalid email format → Error message
- Invalid phone number → Error message
- Past date selection → Prevent selection
- Unavailable time slot → Show "not available" message

### 10.5 Session Management

**Test:**
- Token expiry → Auto-logout with message
- Login from another device → Session conflict handling
- App backgrounded for long time → Re-authenticate

### 10.6 Image Upload Issues

**Test:**
- Large image (>10MB) → Compress or show error
- Invalid file format → Error message
- No camera permission → Request permission
- No storage permission → Request permission

---

## 11. UI/UX CRITICAL CHECKS

### 11.1 SafeArea Implementation (Fixed Issues)

**Verify these screens don't have content behind system navigation bar:**

✅ **Fixed Files:**
1. `bottom_nav_bar.dart` (vendor) - Bottom nav wrapped in SafeArea
2. `custom_nav_bar.dart` (user) - Bottom nav wrapped in SafeArea
3. `chat_user_screen.dart` - Message input in SafeArea
4. `vendor_chat_screen.dart` - Message input in SafeArea
5. `salon_services_card.dart` - Bottom bar in SafeArea
6. `salon_detail_page.dart` - Body in SafeArea(bottom: true)
7. `userReviewScreen.dart` - Screen in SafeArea
8. `map_screen.dart` - Filter bottom sheet in SafeArea (line 1082)
9. `base_tab_screen.dart` - Filter bottom sheet in SafeArea (line 244)
10. `search_card_screen.dart` - Filter bottom sheet in SafeArea (line 579)
11. `salon_list_screen.dart` - Filter bottom sheet in SafeArea (line 663)

**Test on Physical Device:**
- Test on phones with gesture navigation (no physical buttons)
- Test on phones with physical navigation buttons
- Verify all bottom buttons are tappable
- Verify no content hidden behind system UI

### 11.2 Salon Detail Appbar (Fixed)

**File:** `lib/views/user/nav_bar_screens/home/salon_detail_page_appbar.dart`

**Verify:**
- Appbar background is green (kPrimaryColor)
- Back button: Icon (not Image.asset), black color, green circular background
- Share button: Icon (not Image.asset), black color, green circular background
- Both buttons clearly visible and tappable

### 11.3 Rating Display (Fixed)

**Map Screen Bottom Cards:**
- Rating should show actual value from `vendor['avgRating']`
- NOT hardcoded 0.0
- Verify star rating displays correctly

### 11.4 Review Display in Booking Dialogs (Fixed)

**Files:** `past_tab_screen.dart`, `upcoming_tab_screen.dart`, `pending_booking.dart`

**Verify:**
- If user has given review for a vendor, it displays in booking details dialog
- Shows star rating (5-star emoji system)
- Shows review comment
- Shows review date
- Fetched from `/review/user?vendorId=XXX&userId=XXX` API

### 11.5 5-Star Rating System (Fixed)

**File:** `userReviewScreen.dart`

**Verify:**
- 5 emoji options available (not 4)
- Emoji sequence: 😡🙁🙂😃🤩
- Labels: Terrible, Bad, Okay, Good, Excellent
- All 5 stars selectable

---

## 12. PERFORMANCE TESTING

### 12.1 App Launch Time
- Cold start: < 3 seconds
- Warm start: < 1 second

### 12.2 Screen Load Time
- Image-heavy screens: < 2 seconds
- List screens: < 1 second
- Detail screens: < 1.5 seconds

### 12.3 API Response Time
- Search: < 1 second
- Booking creation: < 2 seconds
- Payment processing: Variable (3-5 seconds)

### 12.4 Memory Usage
- Monitor memory leaks
- Check image caching
- Verify proper disposal of controllers

---

## 13. ACCESSIBILITY TESTING

### 13.1 Screen Reader Support
- Test with TalkBack (Android) / VoiceOver (iOS)
- All interactive elements should be labeled
- Proper focus order

### 13.2 Font Scaling
- Test with large font sizes
- Text should remain readable
- No UI breaking

### 13.3 Color Contrast
- Verify WCAG AA compliance
- Text readable on backgrounds

---

## 14. DEVICE-SPECIFIC TESTING

### 14.1 Screen Sizes
- Small phones (< 5 inches)
- Medium phones (5-6 inches)
- Large phones (> 6 inches)
- Tablets

### 14.2 Android Versions
- Android 8.0 (API 26)
- Android 9.0 (API 28)
- Android 10 (API 29)
- Android 11 (API 30)
- Android 12+ (API 31+)

### 14.3 iOS Versions (if applicable)
- iOS 13
- iOS 14
- iOS 15
- iOS 16+

---

## 15. REGRESSION TEST CHECKLIST

After any code change, verify:

- [ ] App launches successfully
- [ ] Login/signup works
- [ ] Home screen loads with data
- [ ] Search functionality works
- [ ] Map displays correctly
- [ ] Filters apply correctly
- [ ] Booking flow completes
- [ ] Payment processes
- [ ] Chat sends messages
- [ ] Reviews submit successfully
- [ ] Profile updates save
- [ ] All bottom navigation tabs work
- [ ] No content behind system navigation bar
- [ ] All buttons are tappable
- [ ] Images load correctly
- [ ] No crashes or freezes

---

## 16. TESTING SIGN-OFF

### Test Execution Date: _______________
### Tested By: _______________
### Device Used: _______________
### OS Version: _______________
### App Version: _______________

### Results Summary:
- Total Tests: _______________
- Passed: _______________
- Failed: _______________
- Blocked: _______________

### Critical Issues Found:
1. _______________
2. _______________
3. _______________

### Sign-off:
- QA Lead: _______________ Date: _______________
- Project Manager: _______________ Date: _______________

---

## NOTES FOR TESTERS

1. **Always test on real devices**, not just emulators
2. **Test with different network speeds** (WiFi, 4G, 3G)
3. **Test with different user accounts** (new user, existing user, vendor)
4. **Document bugs with screenshots/videos**
5. **Verify fixes for all previously reported bugs**
6. **Test both happy path and error scenarios**
7. **Pay special attention to SafeArea implementations** - this was a major fix
8. **Verify rating displays are NOT hardcoded to 0.0**
9. **Check that all 4 filter bottom sheets work correctly**
10. **Confirm 5-star rating system (not 4 stars)**

---

## PRIORITY TESTING AREAS (Based on Recent Fixes)

### 🔴 **HIGH PRIORITY** (Test First)

1. **Filter Bottom Sheets** (4 locations)
   - Verify SafeArea implementation
   - Buttons not hidden behind nav bar
   - All filter options work

2. **Rating Display**
   - Map screen bottom cards show actual ratings
   - Not hardcoded to 0.0

3. **Review System**
   - 5-star emoji system works
   - Reviews display in booking dialogs
   - Submit review flow works

4. **Bottom Navigation Bars**
   - User nav bar (5 tabs)
   - Vendor nav bar (5 tabs)
   - Both wrapped in SafeArea
   - All tabs accessible

5. **Chat Screens**
   - User chat message input not hidden
   - Vendor chat message input not hidden
   - Keyboard handling works

### 🟡 **MEDIUM PRIORITY**

6. **Salon Detail Page**
   - Appbar buttons (green background, black icons)
   - Content not behind nav bar
   - All tabs work

7. **Booking Flow**
   - Complete end-to-end booking
   - Payment processing
   - Confirmation

8. **Search & Filters**
   - Search results
   - Filter application
   - Sort options

### 🟢 **LOW PRIORITY** (Test After High/Medium)

9. **Profile Management**
10. **Notification System**
11. **Wishlist Functionality**
12. **Vendor Management Screens**

---

**END OF TESTING GUIDE**
