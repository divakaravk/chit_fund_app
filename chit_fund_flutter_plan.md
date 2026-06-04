# Chit Fund SaaS — Flutter App Full Implementation Plan
# Give this entire file to Claude Code as the prompt

---

## PROJECT OVERVIEW

Build a production-ready Flutter mobile app for a Chit Fund SaaS platform.
Multiple chit fund companies use this app. Each company has its own login, data, and members.

---

## TECH STACK

- Flutter (latest stable)
- State Management: Riverpod (flutter_riverpod)
- Navigation: GoRouter
- HTTP: Dio (with interceptors)
- Local Storage: SharedPreferences + Flutter Secure Storage
- UI: Custom design system (no generic Material widgets directly — wrap them)
- Fonts: Google Fonts (Poppins)
- Icons: Lucide Icons or Iconsax
- Charts: FL Chart
- Animations: Lottie + Flutter Animate

---

## BACKEND API BASE

Base URL: https://yourdomain.com/chit_fund_saas_api

### Auth Headers (send on every request after login):
- X-User-Id: {logged_in_user_id}
- X-User-Role: {role} — super_admin | admin | foreman | member
- X-Company-Id: {company_id}
- Content-Type: application/json

### API Endpoints:

#### COMPANIES
- POST   /companies/register_company.php     — register new company
- GET    /companies/get_company.php          — get company details
- PUT    /companies/update_company.php       — update company

#### USERS
- POST   /users/add_user.php                 — add user
- GET    /users/get_user.php                 — get all users
- GET    /users/get_user.php?id=xxx          — get single user
- PUT    /users/update_user.php?id=xxx       — update user
- PATCH  /users/patch_user_status.php?id=xxx — change status
- DELETE /users/delete_user.php?id=xxx       — deactivate user

#### CHIT SCHEMES
- POST   /schemes/add_scheme.php
- GET    /schemes/get_scheme.php
- GET    /schemes/get_scheme.php?id=xxx
- PUT    /schemes/update_scheme.php?id=xxx
- PATCH  /schemes/patch_scheme_status.php?id=xxx
- DELETE /schemes/delete_scheme.php?id=xxx

#### CHIT GROUPS
- POST   /groups/add_group.php
- GET    /groups/get_group.php
- GET    /groups/get_group.php?id=xxx
- PUT    /groups/update_group.php?id=xxx
- PATCH  /groups/patch_group_status.php?id=xxx
- DELETE /groups/delete_group.php?id=xxx

#### MEMBERSHIPS
- POST   /memberships/add_membership.php
- GET    /memberships/get_membership.php
- GET    /memberships/get_membership.php?id=xxx
- GET    /memberships/get_membership.php?group_id=xxx
- PUT    /memberships/update_membership.php?id=xxx
- PATCH  /memberships/patch_membership_status.php?id=xxx
- DELETE /memberships/delete_membership.php?id=xxx

#### AUCTION CYCLES
- POST   /auctions/add_auction.php
- GET    /auctions/get_auction.php
- GET    /auctions/get_auction.php?id=xxx
- GET    /auctions/get_auction.php?group_id=xxx
- POST   /auctions/close_auction.php?id=xxx
- DELETE /auctions/delete_auction.php?id=xxx

#### BIDS
- POST   /bids/add_bid.php
- GET    /bids/get_bid.php?auction_id=xxx
- PUT    /bids/update_bid.php?id=xxx
- DELETE /bids/delete_bid.php?id=xxx

#### PAYMENTS
- POST   /payments/add_payment.php
- GET    /payments/get_payment.php
- GET    /payments/get_payment.php?id=xxx
- GET    /payments/get_payment.php?membership_id=xxx
- POST   /payments/mark_paid.php?id=xxx
- DELETE /payments/delete_payment.php?id=xxx

#### DISBURSEMENTS
- POST   /disbursements/add_disbursement.php
- POST   /disbursements/confirm_disbursement.php?id=xxx
- DELETE /disbursements/delete_disbursement.php?id=xxx

#### SURETY BONDS
- POST   /surety_bonds/add_surety_bond.php
- PUT    /surety_bonds/update_surety_bond.php?id=xxx
- DELETE /surety_bonds/delete_surety_bond.php?id=xxx

#### NOTIFICATIONS
- POST   /notifications/add_notification.php
- GET    /notifications/get_notification.php
- PATCH  /notifications/mark_read.php?id=xxx
- DELETE /notifications/delete_notification.php?id=xxx

#### AUDIT LOGS
- GET    /audit_logs/get_audit_logs.php
- GET    /audit_logs/get_audit_logs.php?entity_type=xxx&entity_id=xxx

---

## FOLDER STRUCTURE

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_sizes.dart
│   │   └── app_strings.dart
│   ├── network/
│   │   ├── dio_client.dart          — Dio setup with interceptors
│   │   ├── api_endpoints.dart       — all endpoint strings
│   │   └── api_response.dart        — generic response model
│   ├── storage/
│   │   └── local_storage.dart       — SharedPreferences wrapper
│   ├── router/
│   │   └── app_router.dart          — GoRouter all routes
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       └── snackbar_helper.dart
├── models/
│   ├── company_model.dart
│   ├── user_model.dart
│   ├── scheme_model.dart
│   ├── group_model.dart
│   ├── membership_model.dart
│   ├── auction_model.dart
│   ├── bid_model.dart
│   ├── payment_model.dart
│   ├── disbursement_model.dart
│   ├── surety_bond_model.dart
│   └── notification_model.dart
├── services/
│   ├── auth_service.dart
│   ├── company_service.dart
│   ├── user_service.dart
│   ├── scheme_service.dart
│   ├── group_service.dart
│   ├── membership_service.dart
│   ├── auction_service.dart
│   ├── bid_service.dart
│   ├── payment_service.dart
│   ├── disbursement_service.dart
│   ├── surety_bond_service.dart
│   └── notification_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── company_provider.dart
│   ├── user_provider.dart
│   ├── scheme_provider.dart
│   ├── group_provider.dart
│   ├── membership_provider.dart
│   ├── auction_provider.dart
│   ├── payment_provider.dart
│   └── notification_provider.dart
└── screens/
    ├── splash/
    │   └── splash_screen.dart
    ├── onboarding/
    │   └── onboarding_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_company_screen.dart
    ├── dashboard/
    │   └── dashboard_screen.dart
    ├── users/
    │   ├── users_list_screen.dart
    │   ├── add_user_screen.dart
    │   └── user_detail_screen.dart
    ├── schemes/
    │   ├── schemes_list_screen.dart
    │   ├── add_scheme_screen.dart
    │   └── scheme_detail_screen.dart
    ├── groups/
    │   ├── groups_list_screen.dart
    │   ├── add_group_screen.dart
    │   └── group_detail_screen.dart
    ├── memberships/
    │   ├── memberships_list_screen.dart
    │   └── add_membership_screen.dart
    ├── auctions/
    │   ├── auctions_list_screen.dart
    │   ├── add_auction_screen.dart
    │   └── auction_detail_screen.dart
    ├── payments/
    │   ├── payments_list_screen.dart
    │   └── add_payment_screen.dart
    ├── notifications/
    │   └── notifications_screen.dart
    └── profile/
        └── profile_screen.dart
```

---

## DESIGN SYSTEM

### Color Palette:
```dart
primary:        #1E3A5F   — deep navy blue
primaryLight:   #2D5F9E   — medium blue
accent:         #F4A623   — golden amber
accentLight:    #FFD166   — light gold
success:        #06D6A0   — emerald green
warning:        #FFB703   — amber
error:          #EF476F   — coral red
background:     #F8F9FE   — off white
surface:        #FFFFFF
cardBg:         #FFFFFF
textPrimary:    #1A1D2E
textSecondary:  #6B7280
textHint:       #9CA3AF
divider:        #E5E7EB
```

### Typography (Poppins):
- Display: Poppins 28sp Bold
- Heading: Poppins 22sp SemiBold
- Title: Poppins 18sp SemiBold
- Subtitle: Poppins 16sp Medium
- Body: Poppins 14sp Regular
- Caption: Poppins 12sp Regular
- Label: Poppins 12sp Medium

### Spacing: 4, 8, 12, 16, 20, 24, 32, 40, 48
### Border Radius: small=8, medium=12, large=16, xl=24, pill=100

---

## SCREENS — DETAILED SPEC

### 1. SPLASH SCREEN
- Full screen gradient: primary → primaryLight
- Center: App logo (coin/chit icon) with Lottie animation
- App name: "ChitFlow" in white Poppins Bold 32sp
- Tagline: "Smart Chit Fund Management"
- Auto navigate after 2.5s:
  - If token exists → Dashboard
  - Else → Onboarding

### 2. ONBOARDING SCREEN
- 3 slides with PageView
  - Slide 1: "Manage Multiple Groups" — group icon animation
  - Slide 2: "Track Payments Easily" — payment icon animation
  - Slide 3: "Auction Made Simple" — auction gavel animation
- Dot indicators
- Skip button (top right)
- Next / Get Started buttons
- Navigate to Login on finish

### 3. LOGIN SCREEN (Most Important — Top Notch UI)
- Background: gradient top half primary color, bottom half white
- Top section:
  - Back curved white card overlay
  - App logo small + "Welcome Back" text
- Form card (elevated, rounded 24):
  - Company Code field (with building icon)
  - Phone Number field (with phone icon)
  - Role dropdown: admin / foreman / member
  - "Login" button — full width, gradient primary→primaryLight, rounded pill
- Bottom: "New Company? Register here" link
- Loading state: button shows CircularProgressIndicator
- Error state: shake animation on form card + red snackbar
- On success: save to secure storage → navigate to Dashboard

### 4. REGISTER COMPANY SCREEN
- Step progress indicator (Step 1 of 2, Step 2 of 2)
- Step 1 — Company Info:
  - Company Name
  - Company Code (unique)
  - Owner Name
  - Email
  - Phone
- Step 2 — Confirm:
  - Summary card showing entered info
  - "Confirm & Register" button
- Success: show success Lottie animation → go to Login

### 5. DASHBOARD SCREEN
- Top app bar:
  - Left: "Good Morning, {name}" greeting
  - Right: notification bell (badge count) + avatar
- Summary cards row (horizontal scroll):
  - Total Groups (blue card)
  - Active Members (green card)
  - Pending Payments (amber card)
  - This Month Collections (purple card)
- Quick Actions grid (2x2):
  - Add Member, New Auction, Record Payment, View Reports
- Recent Activity list (last 5 actions from audit log)
- Upcoming Auctions section (next 3 auctions)
- Bottom Navigation Bar:
  - Home, Groups, Payments, Members, Profile

### 6. USERS LIST SCREEN
- Search bar at top
- Filter chips: All / Admin / Foreman / Member / Inactive
- User cards with:
  - Avatar (initials colored circle)
  - Name + Role chip
  - Phone number
  - Status indicator dot
  - Arrow icon
- FAB: Add User
- Swipe to deactivate (left swipe = red delete action)

### 7. ADD USER SCREEN
- AppBar: "Add New Member"
- Form:
  - Full Name (text field)
  - Phone Number (number field)
  - Role (dropdown with icons)
  - Address (expandable section)
    - Street
    - City
    - State
    - Pincode
- Submit button with loading state
- Success: pop with success snackbar

### 8. USER DETAIL SCREEN
- Profile header: large avatar + name + role chip + status
- Info cards:
  - Contact info
  - Memberships list (which groups they're in)
  - Payment history
  - Surety bonds
- Edit button (top right)
- Deactivate button (bottom, outlined red)

### 9. SCHEMES LIST SCREEN
- Header stats: Total Schemes count
- Scheme cards:
  - Scheme name + code
  - Chit amount (large, bold)
  - Duration + Members + Bid type chips
  - Status badge
- FAB: Add Scheme
- Empty state illustration when no schemes

### 10. ADD SCHEME SCREEN
- Form:
  - Scheme Name
  - Scheme Code
  - Chit Amount (with ₹ prefix)
  - Duration Months (slider or number)
  - Total Members (number)
  - Monthly Contribution (auto-calculated from chit_amount/duration)
  - Foreman Commission % (slider 0-10%)
  - Bid Type (segmented control: Open / Sealed / Lucky Draw)
- Preview card at bottom showing calculated values

### 11. GROUPS LIST SCREEN
- Group cards:
  - Group code (prominent)
  - Scheme name
  - Current month / Total months progress bar
  - Member count
  - Status chip
  - Next auction date
- Filter: Active / Paused / Completed
- FAB: Add Group

### 12. GROUP DETAIL SCREEN
- Header: Group code + status + scheme name
- Progress bar: Month X of Y
- Tabs:
  - Overview (key stats)
  - Members (membership list)
  - Auctions (auction cycles)
  - Payments (payment records)
- Each tab lazy loads data

### 13. AUCTIONS LIST SCREEN
- Upcoming auctions (highlighted section)
- Past auctions list
- Auction card:
  - Cycle month + date
  - Prize pool amount
  - Status chip (scheduled/open/closed)
  - Winner name (if closed)
- FAB: Schedule New Auction

### 14. AUCTION DETAIL SCREEN
- Prize pool amount (large)
- Auction date + status
- Bids section (if open/scheduled):
  - List of bids with amounts
  - Highest bid highlighted
- Close Auction button (admin only):
  - Opens bottom sheet to confirm winner + enter commission + dividend
- Winner card (if closed)

### 15. PAYMENTS LIST SCREEN
- Summary at top:
  - Total Collected this month
  - Pending count
  - Overdue count
- Filter: All / Pending / Paid / Overdue
- Payment cards:
  - Member name
  - Amount
  - Due date
  - Status chip
- Swipe right = mark as paid
- FAB: Record Payment

### 16. NOTIFICATIONS SCREEN
- Grouped by Today / Yesterday / Earlier
- Notification cards with icon per type:
  - 💰 payment_due
  - 🔨 auction_result
  - 💸 disbursement
  - 📢 general
- Unread = white bg, Read = grey bg
- Tap to mark as read
- Swipe to delete

### 17. PROFILE SCREEN
- Company info card (logo + name + plan badge)
- User info (name + role + phone)
- Settings sections:
  - Company Settings (admin only)
  - Change Role / Switch User
  - Notifications toggle
  - App Theme (light/dark toggle)
  - Logout button (red)

---

## IMPORTANT IMPLEMENTATION NOTES

### Auth Flow:
```
Login → Company Code + Phone + Role
      → POST to get_user.php?company_code=xxx&phone=xxx
      → Save: userId, userRole, companyId, userName to SecureStorage
      → All subsequent API calls use these as headers
```

Note: There is no separate login endpoint in the backend.
The login works by:
1. First call GET /companies/get_company.php — find company by company_code
2. Then call GET /users/get_user.php — find user by phone in that company
3. Validate role matches
4. Save to local storage and proceed

### Dio Interceptor (attach to every request):
```dart
options.headers['X-User-Id']    = await storage.getUserId();
options.headers['X-User-Role']  = await storage.getUserRole();
options.headers['X-Company-Id'] = await storage.getCompanyId();
options.headers['Content-Type'] = 'application/json';
```

### Error Handling:
- 401 → clear storage → redirect to login
- 403 → show "Permission denied" snackbar
- 409 → show conflict message from API
- 500 → show "Server error, try again" snackbar
- No internet → show offline banner

### Role-based UI:
```
super_admin : everything visible
admin       : everything except company billing
foreman     : groups, memberships, auctions, payments (their groups only)
member      : own membership, payments, notifications only
```

### Indian Formatting:
- Currency: ₹1,00,000 (Indian format)
- Phone: +91 XXXXX XXXXX
- Date: DD MMM YYYY (15 Jan 2025)

---

## PUBSPEC.YAML DEPENDENCIES

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0
  dio: ^5.4.3
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  lottie: ^3.1.0
  fl_chart: ^0.68.0
  iconsax: ^0.0.8
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  another_flushbar: ^1.12.30
```

---

## BUILD ORDER (Claude Code should follow this sequence)

1. pubspec.yaml — add all dependencies
2. core/constants/ — colors, text styles, sizes, strings
3. core/network/dio_client.dart — Dio with interceptors
4. core/network/api_endpoints.dart — all endpoint constants
5. core/storage/local_storage.dart — secure storage wrapper
6. core/router/app_router.dart — all GoRouter routes
7. models/ — all 11 model classes with fromJson/toJson
8. services/ — all service classes calling API
9. providers/ — Riverpod providers for state
10. screens/splash/ — splash screen
11. screens/onboarding/ — onboarding
12. screens/auth/login_screen.dart — LOGIN (most important UI)
13. screens/auth/register_company_screen.dart
14. screens/dashboard/dashboard_screen.dart
15. screens/users/ — list, add, detail
16. screens/schemes/ — list, add, detail
17. screens/groups/ — list, add, detail
18. screens/memberships/ — list, add
19. screens/auctions/ — list, add, detail
20. screens/payments/ — list, add
21. screens/notifications/
22. screens/profile/
23. main.dart + app.dart — wire everything together

---

## FINAL INSTRUCTION TO CLAUDE CODE

Build the complete Flutter app following every spec above exactly.
- Use Poppins font throughout
- Every screen must have proper loading states (shimmer)
- Every API call must have error handling
- Forms must have validation
- Use Riverpod for ALL state management
- Use GoRouter for ALL navigation
- The login screen and dashboard must be especially polished
- Indian Rupee formatting everywhere money is shown
- The app name is "ChitFlow"
- App icon color: primary #1E3A5F

Start building now. Do not ask for clarification — follow the spec.
