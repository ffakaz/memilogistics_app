# Installation & Testing Instructions

## Build Status
✅ **APK Built Successfully**
- **File:** `build\app\outputs\flutter-apk\app-release.apk`
- **Size:** 52.7 MB
- **Build Time:** 751 seconds (~12.5 minutes)
- **Build Date:** May 29, 2026

---

## Installation Steps

### Step 1: Uninstall Old Version
```bash
adb uninstall com.example.memilogistics_app
```

**Expected Output:**
```
Success
```

### Step 2: Install New Version
```bash
adb install "build\app\outputs\flutter-apk\app-release.apk"
```

**Expected Output:**
```
Performing Streamed Install
Success
```

### Step 3: View Console Logs
```bash
adb logcat -s flutter
```

This will show all Flutter debug logs including our new logging statements.

---

## What Was Fixed

### 1. Shipment List Auto-Refresh ✅
- **Issue:** New shipments didn't appear in "My Shipments" list after creation
- **Fix:** Added automatic refresh after shipment creation
- **Files Modified:**
  - `lib/features/shipment/presentation/screens/create_shipment_screen.dart`
  - `lib/features/shipment/presentation/screens/my_shipments_screen.dart`

### 2. Enhanced Offers Debugging 🔍
- **Issue:** Shipper not seeing carrier offers in mobile app (works in frontend)
- **Fix:** Added comprehensive logging to identify root cause
- **Files Modified:**
  - `lib/features/shipment/data/services/shipment_api_service_real.dart`
  - `lib/features/shipment/presentation/screens/shipment_offers_screen.dart`

---

## Testing Scenarios

### Test 1: Shipment List Auto-Refresh

**Steps:**
1. Login as shipper
2. Navigate to "My Shipments" screen
3. Note the current number of shipments
4. Tap "Create Shipment" button
5. Fill in shipment details:
   - Shipment Item: "Electronics"
   - Weight: 100 kg
   - Origin: "Addis Ababa"
   - Destination: "Mekelle"
   - Pickup Date: Tomorrow
   - Fragile: Yes
6. Tap "Create Shipment"

**Expected Results:**
- ✅ Success message appears
- ✅ Screen navigates back to "My Shipments"
- ✅ New shipment appears immediately in the list
- ✅ No need to manually refresh

**Console Logs to Check:**
```
📋 Creating shipment with Shipper ID: X
✅ Refreshed shipments list after creation
📦 Fetching my shipments (role-aware) using /shipment/my endpoint...
📦 Received N shipments from backend
```

---

### Test 2: Pull-to-Refresh

**Steps:**
1. On "My Shipments" screen
2. Pull down from the top of the list
3. Release

**Expected Results:**
- ✅ Loading indicator appears
- ✅ List refreshes with latest data
- ✅ Any new shipments appear

---

### Test 3: Offers Display & Debugging

**Setup:**
1. Have a shipper account with at least one shipment
2. Have a carrier account
3. Carrier makes an offer on the shipment (via mobile or frontend)

**Steps:**
1. Login as shipper
2. Navigate to "My Shipments"
3. Tap the offer icon (🏷️) on a shipment
4. **Keep console logs open** (`adb logcat -s flutter`)

**Expected Console Logs:**
```
🔍 [ShipmentOffers] Fetching offers for shipment X
✅ [ShipmentOffers] Shipment found: TRACK-XXX
📡 [ShipmentOffers] Calling API: /api/shipments/X/offers
🔍 [API] Fetching offers for shipment X
   Endpoint: /api/shipment/X/offers
   Response status: 200
   Response data type: List
   Response data: [...]
   ✅ Parsed N offers successfully
📥 [ShipmentOffers] Received N offers from backend
```

**If Offers Show:**
- ✅ Carrier company name displayed
- ✅ Offer price displayed
- ✅ "Accept" and "Reject" buttons work
- ✅ Confirmation dialogs appear

**If No Offers Show:**
Check console logs for:
1. **Empty response:** `📥 [ShipmentOffers] Received 0 offers from backend`
   - **Cause:** Backend has no offers for this shipment
   - **Action:** Verify carrier actually created offers in backend database

2. **API Error:** `❌ [ShipmentOffers] Error loading offers: <error>`
   - **Cause:** Authentication, network, or backend issue
   - **Action:** Check error message for details

3. **Parsing Error:** `❌ Error fetching offers: <error>`
   - **Cause:** Data structure mismatch
   - **Action:** Check backend response format

---

### Test 4: Accept Offer

**Steps:**
1. From offers screen (as shipper)
2. Tap "Accept" on an offer
3. Confirm in dialog

**Expected Results:**
- ✅ Success message appears
- ✅ Shipment status changes to "assigned"
- ✅ Offer list refreshes

**Console Logs:**
```
Assigning carrier X to shipment Y
✅ Carrier assigned successfully
```

---

### Test 5: Reject Offer

**Steps:**
1. From offers screen (as shipper)
2. Tap "Reject" on an offer
3. Confirm in dialog

**Expected Results:**
- ✅ Success message appears
- ✅ Offer disappears from list
- ✅ Offer list refreshes

---

## Troubleshooting

### Issue: APK Won't Install
**Error:** `INSTALL_FAILED_UPDATE_INCOMPATIBLE`

**Solution:**
```bash
adb uninstall com.example.memilogistics_app
adb install "build\app\outputs\flutter-apk\app-release.apk"
```

---

### Issue: Can't See Console Logs
**Problem:** `adb logcat` shows too much output

**Solution:**
```bash
# Filter for Flutter logs only
adb logcat -s flutter

# Or filter for specific tags
adb logcat | findstr "ShipmentOffers"
adb logcat | findstr "API"
```

---

### Issue: Offers Still Don't Show

**Debugging Steps:**

1. **Verify Backend Has Offers:**
   - Check backend database directly
   - Use Postman/curl to call: `GET https://memi-logistics-backend.onrender.com/api/shipment/{shipmentId}/offers`
   - Include Bearer token in Authorization header

2. **Compare Frontend vs Mobile:**
   - Open browser dev tools on frontend
   - Check Network tab for offers API call
   - Compare request headers (especially Authorization)
   - Compare response data

3. **Check Authentication:**
   - Verify token is being sent: Look for `Authorization: Bearer <token>` in logs
   - Verify token is not expired
   - Try logging out and back in

4. **Check ProGuard Rules:**
   - Verify `android/app/proguard-rules.pro` has `-dontobfuscate`
   - This prevents token storage issues

---

## API Endpoints Reference

### Shipment Controller (Returns Data)
```
GET  /api/shipment/my                    → My shipments (role-aware)
GET  /api/shipment/{shipmentId}/offers   → Offers for shipment ✅
POST /api/shipment/create                → Create shipment
```

### Shipment Assignment Controller (Returns 200 OK)
```
POST /api/shipments/{shipmentId}/offer-shipment?price=X           → Create offer
POST /api/shipments/{shipmentId}/assign-carrier?carrierId=X       → Accept offer
POST /api/shipments/{shipmentOfferId}/cancel-shipment-offer       → Reject offer
```

---

## Next Steps

1. **Install APK** on device using instructions above
2. **Test shipment creation** and verify auto-refresh works
3. **Test offers display** with console logs open
4. **Report findings:**
   - If offers show: ✅ Issue resolved!
   - If offers don't show: Share console logs to identify root cause

---

## Files Modified

### This Session:
1. `lib/features/shipment/data/services/shipment_api_service_real.dart`
   - Added logging to `getShipmentOffers()`

2. `lib/features/shipment/presentation/screens/my_shipments_screen.dart`
   - Fixed syntax error

### Previous Session:
1. `lib/features/shipment/presentation/screens/create_shipment_screen.dart`
   - Added `getMyShipments()` call after creation

2. `lib/features/shipment/presentation/screens/my_shipments_screen.dart`
   - Added `RefreshIndicator` for pull-to-refresh
   - Added `didChangeDependencies()` for auto-refresh

3. `lib/features/shipment/presentation/screens/shipment_offers_screen.dart`
   - Added comprehensive logging

---

## Success Criteria

✅ **Shipment List:**
- New shipments appear immediately after creation
- Pull-to-refresh works
- List updates when returning to screen

🔍 **Offers Display:**
- Console logs show API calls and responses
- Can identify root cause if offers don't show
- Accept/Reject functionality works when offers are present

---

## Support

If issues persist after testing:
1. Share console logs (`adb logcat -s flutter`)
2. Share screenshots of error messages
3. Verify backend has offers in database
4. Compare frontend network requests vs mobile app requests
