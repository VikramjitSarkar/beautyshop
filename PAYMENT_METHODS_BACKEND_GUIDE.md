# Payment Methods Feature - Backend Implementation Guide

## Overview
A new payment method selection feature has been added to the vendor registration flow. Vendors can now select which payment methods they accept, and these will be displayed on their profiles on the user side.

## Database Schema Update

### Vendor Model
Add a new field to the vendor schema:

```javascript
{
  paymentMethods: {
    type: [String],
    enum: ['paypal', 'stripe', 'razorpay', 'cash', 'card', 'bank_transfer'],
    default: []
  }
}
```

## API Endpoints Required

### 1. Update Payment Methods
**Endpoint:** `PUT /vendor/updatePaymentMethods`

**Headers:**
- `Authorization: Bearer <vendorToken>`
- `Content-Type: application/json`

**Request Body:**
```json
{
  "paymentMethods": ["cash", "card", "stripe", "paypal"]
}
```

**Response (Success - 200/201):**
```json
{
  "status": "success",
  "message": "Payment methods updated successfully",
  "data": {
    "_id": "vendorId",
    "paymentMethods": ["cash", "card", "stripe", "paypal"],
    ...other vendor fields
  }
}
```

**Response (Error - 400):**
```json
{
  "status": "error",
  "message": "Invalid payment method provided"
}
```

### 2. Get Vendor Details (Update existing endpoint)
**Endpoint:** `GET /vendor/get`

**Headers:**
- `Authorization: Bearer <vendorToken>`

**Response:**
Ensure the response includes the `paymentMethods` array:
```json
{
  "status": "success",
  "data": {
    "_id": "vendorId",
    "userName": "Vendor Name",
    "paymentMethods": ["cash", "card", "paypal"],
    ...other vendor fields
  }
}
```

### 3. Get All Vendors (Update existing endpoint)
**Endpoint:** `GET /vendor/getAll`

**Response:**
Ensure each vendor object in the response includes `paymentMethods`:
```json
{
  "status": "success",
  "data": [
    {
      "_id": "vendorId",
      "shopName": "Shop Name",
      "paymentMethods": ["cash", "card", "stripe"],
      ...other vendor fields
    }
  ]
}
```

## Validation Rules

1. **paymentMethods** must be an array
2. Each element must be one of: `'paypal'`, `'stripe'`, `'razorpay'`, `'cash'`, `'card'`, `'bank_transfer'`
3. Array can be empty (no payment methods selected)
4. Duplicates should be automatically removed
5. Case-insensitive validation (convert to lowercase before saving)

## Implementation Notes

1. The payment methods are saved as lowercase strings in the database
2. When updating payment methods, replace the entire array (don't append/remove individual items)
3. The payment methods will be displayed as tags on the vendor profile in the user app
4. Vendors can update their payment methods later from Settings > Payment Methods

## Frontend Integration Points

### Vendor Registration Flow:
1. Profile Setup Screen (existing)
2. **Payment Method Selection Screen (new)** ← Insert here
3. Free/Paid Listing Services Screen (existing)

### Settings:
- Added "Payment Methods" option in vendor settings to edit payment methods later

### User Side Display:
- Payment methods are shown as icon + text tags on the vendor detail page
- Located above the tab bar, below the service type tags

## Testing Checklist

- [ ] Vendor can select multiple payment methods during registration
- [ ] Vendor can skip payment method selection (empty array)
- [ ] Payment methods are saved correctly in database
- [ ] Vendor can update payment methods from settings
- [ ] Payment methods display correctly on user side vendor profiles
- [ ] Invalid payment methods are rejected with proper error message
- [ ] Authorization token validation works correctly
- [ ] Payment methods persist across app sessions

## Payment Method Icons Mapping

Frontend uses these icons for display:
- **PayPal**: `Icons.payment`
- **Stripe**: `Icons.credit_card`
- **Razorpay**: `Icons.account_balance_wallet`
- **Cash**: `Icons.money`
- **Card**: `Icons.credit_card_outlined`
- **Bank Transfer**: `Icons.account_balance`
