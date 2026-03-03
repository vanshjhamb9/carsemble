# FKM LMS Mobile App – Backend Integration Guide

This guide lists all app features that depend on the backend, documents how **login** and **signup** work, and gives actionable steps so you can implement or verify the backend.

---

## 1. App → Backend connection

| Item | Location | Value |
|------|----------|--------|
| Base URL | `lib/common/utils/constants.dart` | `dommain` + `/api/development/` |
| API key header | All requests | `x-api-key: 1234` (from `Constants.apiKey`) |
| Locale header | All requests | `x-locale: <language>` (e.g. `en`, `ar`) |
| Auth header (when logged in) | Protected requests | `Authorization: Bearer <token>` |

**Action:** In `constants.dart`, set `dommain` to your backend base URL (no trailing slash). Ensure the backend serves APIs under `{baseUrl}/api/development/` (or change the path in the app to match your backend).

---

## 2. Features that depend on the backend

### 2.1 Guest (no login)

| Feature | Service | Endpoints | Auth |
|--------|---------|-----------|------|
| App config (currency, register method, social login flags) | `GuestService` | `GET config` | No |
| Register config (fields per role) | `GuestService` | `GET config/register/{role}` | No |
| Currencies | `GuestService` | `GET currency/list` | No |
| Timezones | `GuestService` | `GET timezones` | No |
| Categories | `CategoriesService` | `GET trend-categories`, `GET categories`, `GET categories/{id}/webinars` | No |
| Courses & bundles | `CourseService` | `GET courses`, `GET bundles`, `GET featured-courses`, `GET bundles/{id}/webinars`, `GET courses/{id}`, `GET bundles/{id}`, `GET panel/webinars/{id}`, `GET panel/bundles/{id}` | Optional token for “my course” view |
| Course content | `CourseService` | `GET courses/{courseId}/content` | Yes (for purchased) |
| Search | `CourseService` | `GET search?search={text}` | No |
| Report reasons | `CourseService` | `GET courses/reports/reasons` | No |
| Locations | `LocationService` | `GET regions/countries`, `regions/provinces/{id}`, `regions/cities/{id}`, `regions/districts/{id}` | No |
| Providers (instructors / orgs / consultations) | `ProvidersService` | `GET providers/instructors`, `providers/organizations`, `providers/consultations` | No |
| Blogs | `BlogService` | `GET blogs`, `GET blogs/categories` | No |

### 2.2 Authentication (login / signup)

| Feature | Service | Endpoints | Auth |
|--------|---------|-----------|------|
| Login (email or phone) | `AuthenticationService` | `POST login` | No |
| Google login | `AuthenticationService` | `POST google/callback` | No |
| Facebook login | `AuthenticationService` | `POST facebook/callback` | No |
| Register step 1 (email or phone) | `AuthenticationService` | `POST register/step/1` | No |
| Register step 2 (verify code) | `AuthenticationService` | `POST register/step/2` | No |
| Register step 3 (name, referral) | `AuthenticationService` | `POST register/step/3` | No |
| Forget password | `AuthenticationService` | `POST forget-password` | No |
| Logout | `UserService` | `POST logout` | Yes |

### 2.3 User panel (requires login)

| Feature | Service | Endpoints | Method |
|--------|---------|-----------|--------|
| Profile & settings | `UserService` | `GET panel/profile-setting`, `PUT panel/profile-setting`, `PUT panel/profile-setting/password`, `PUT panel/profile-setting/images` | GET/PUT |
| Quick info | `UserService` | `GET panel/quick-info` | GET |
| Purchases / my courses | `UserService` | `GET panel/webinars/purchases`, `GET panel/webinars/organization` | GET |
| Favorites | `UserService` | `GET panel/favorites`, `DELETE panel/favorites/{id}`, `POST panel/favorites/toggle2` | GET/DELETE/POST |
| Notifications | `UserService` | `GET panel/notifications`, `GET panel/notifications/{id}/read` | GET |
| Login history | `UserService` | `GET panel/users/login/history` | GET |
| CSRF token | `UserService` | `GET panel/csrf-token` | GET |
| Delete account request | `UserService` | `POST panel/delete-account-request` | POST |
| Classes | `UserService` | `GET panel/classes` | GET |
| Reviews | `UserService` | `POST panel/reviews` | POST |
| FCM (push) | `UserService` | `PUT panel/users/fcm` | PUT |
| Rewards | `UserService`, `RewardsService` | `GET panel/rewards`, `POST panel/rewards/webinar/{id}/apply` | GET/POST |
| Cart | `CartService` | `GET panel/cart/list`, `POST panel/cart/store`, `POST panel/cart`, `DELETE panel/cart/{id}`, `POST panel/cart/checkout`, `POST panel/cart/coupon/validate`, `POST panel/cart/web_checkout` | Various |
| Payments | `CartService` | `POST panel/payments/request`, `POST panel/payments/credit` | POST |
| Subscribe apply | `CartService` | `POST panel/subscribe/apply` | POST |
| Certificates | `CertificateService` | `GET panel/certificates/achievements`, `GET panel/webinars/certificates`, `GET panel/certificates/created` | GET |
| Meetings | `MeetingService` | `GET panel/meetings`, `GET panel/meetings/{id}`, `POST panel/meetings/{id}/finish`, `POST instructor/meetings/create-link`, `POST instructor/meetings/{id}/add-session`, `POST instructor/meetings/{id}/finish` | GET/POST |
| Assignments (student) | `AssignmentService` | `GET panel/my_assignments`, `GET panel/assignments/{id}/messages`, POST messages (FormData) | GET/POST |
| Assignments (instructor) | `AssignmentService` | `GET instructor/assignments`, `GET instructor/assignments/{id}/students`, `POST instructor/assignments/histories/{id}/rate` | GET/POST |
| Forum | `ForumService` | `GET panel/webinars/{id}/forums`, `POST panel/webinars/forums/{id}/answers`, `GET panel/webinars/forums/{id}/answers`, `POST panel/webinars/forums/answers/{id}/pin`, `POST panel/webinars/forums/answers/{id}/resolve`, `POST panel/webinars/forums/{id}/pin`, FormData create topic | GET/POST |
| Comments | `CommentsService` | `GET panel/comments`, `POST panel/comments`, `POST panel/comments/{id}/reply`, `PUT panel/comments/{id}`, `DELETE panel/comments/{id}`, `POST panel/comments/{id}/report` | GET/POST/PUT/DELETE |
| Blog comments | `BlogService` | `POST panel/comments`, `POST panel/comments/{id}/report` | POST |
| Financial | `FinancialService` | `GET panel/financial/platform-bank-accounts`, `GET panel/financial/offline-payments`, `POST panel/financial/offline-payments`, `GET panel/financial/summary`, `POST panel/financial/web_charge`, `GET panel/financial/payout`, `POST panel/financial/payout`, `GET panel/financial/sales` | GET/POST |
| Quizzes | `QuizService` | `GET panel/quizzes/not_participated`, `GET panel/quizzes/{id}/start`, `GET panel/quizzes/{id}/result`, `POST panel/quizzes/{id}/store-result`, `GET panel/quizzes/results/my-results`, `GET panel/quizzes/results/my-student-result`, `GET panel/quizzes/results/{id}`, `POST panel/quizzes/results/{id}/review` | GET/POST |
| Instructor quizzes | `QuizService` | `GET instructor/quizzes/list` | GET |
| Personal notes | `PersonalNoteService` | `GET panel/webinars/personal-notes`, `GET panel/webinars/personal-notes?item={id}&type={type}`, `DELETE panel/webinars/personal-notes/delete/{id}` | GET/DELETE |
| Support | `SupportService` | `GET panel/support/my_class_support`, `GET panel/support/class_support`, `GET panel/support/tickets`, `GET panel/support/departments`, `GET panel/support/{id}`, `POST panel/support` (FormData), `POST panel/support/{id}/conversations` (FormData) | GET/POST |
| Purchase free course/bundle | `PurchaseService` | `POST panel/webinars/{id}/free`, `POST panel/bundles/{id}/free` | POST |
| Subscription | `SubscriptionService` | `GET panel/subscribe`, `POST panel/subscribe/web_pay`, `GET panel/registration-packages`, `POST panel/registration-packages/pay` | GET/POST |
| Providers (profile, follow, meetings, reserve, send message) | `ProvidersService` | `GET users/{id}/profile`, `POST panel/users/{id}/follow`, `GET users/{id}/meetings?date=`, `POST meetings/reserve`, `POST users/{id}/send-message` | GET/POST |
| Course report / noticeboards / toggle | `CourseService` | `POST courses/{id}/report`, `POST courses/{id}/toggle`, `GET panel/webinars/{id}/noticeboards` | GET/POST |

---

## 3. How login works

### 3.1 Flow in the app

1. User enters **email** (or **phone** with country code) and **password** on `LoginPage`.
2. App calls `AuthenticationService.login(username, password)`.
3. **Username** sent to API:
   - **Email:** `username = mailController.text.trim()` (e.g. `user@example.com`).
   - **Phone:** `username = countryCode.dialCode.replaceAll('+', '') + phoneNumber` (e.g. `11234567890`).
4. On success, app saves `data.token` via `AppData.saveAccessToken(...)` and navigates to main app.
5. On 401 from any authenticated request, app redirects to Login.

### 3.2 Login API contract (backend must implement)

- **URL:** `POST {baseUrl}login`
- **Headers:**  
  `Content-Type: application/json`  
  `Accept: application/json`  
  `x-api-key: <Constants.apiKey>`  
  `x-locale: <language>`
- **Body (JSON):**
  ```json
  {
    "username": "user@example.com",
    "password": "user_password"
  }
  ```
  For phone login, `username` is the full number (e.g. `11234567890`).

- **Success (200):**
  ```json
  {
    "success": true,
    "data": {
      "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
    }
  }
  ```
- **Failure:** HTTP non-200 or `success: false`; app shows error from backend message.

**Action:** Implement `POST .../api/development/login` that accepts `username` (email or full phone) and `password`, validates user, returns a JWT (or same format) in `data.token`. Use the same token in `Authorization: Bearer <token>` for all protected routes.

---

## 4. How signup (registration) works

### 4.1 Flow in the app

1. **Config:** App loads `GET config` at splash; then for register screen may load `GET config/register/{role}` (`user` / `teacher` / `organization`) to get custom fields.
2. **Step 1 – Create account (email or phone):**
   - **Email:** `AuthenticationService.registerWithEmail(registerMethod, email, password, repeatPassword, accountType, fields)`  
     → `POST register/step/1` with `register_method`, `email`, `password`, `password_confirmation`, optional `fields`.
   - **Phone:** `AuthenticationService.registerWithPhone(...)`  
     → same endpoint with `country_code`, `mobile`, `password`, `password_confirmation`, optional `fields`.
3. Backend may return:
   - `success: true` and token → user is fully registered, app logs in.
   - `status: 'go_step_2'` and `data.user_id` → app goes to **verify code** (Step 2).
   - `status: 'go_step_3'` and `data.user_id` → app skips verification and goes to **name/referral** (Step 3).
4. **Step 2 – Verify code:**  
   `POST register/step/2` with `user_id`, `code`. On success, app proceeds to Step 3.
5. **Step 3 – Name and referral:**  
   `POST register/step/3` with `user_id`, `full_name`, `referral_code`. Response must include `data.token`; app saves it and navigates to main app.

### 4.2 Register API contracts

**Step 1 – Email**

- **URL:** `POST {baseUrl}register/step/1`
- **Body (JSON):**
  ```json
  {
    "register_method": "email",
    "country_code": null,
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
  ```
  Optional: `"fields": "<stringified map of custom field id -> value>"` (e.g. from register config).

**Step 1 – Phone**

- **URL:** `POST {baseUrl}register/step/1`
- **Body (JSON):**
  ```json
  {
    "register_method": "phone",
    "country_code": "+1",
    "mobile": "1234567890",
    "password": "password123",
    "password_confirmation": "password123"
  }
  ```
  Optional: `fields` same as above.

**Response (step 1):**

- Immediate success: `{ "success": true, "data": { "token": "..." } }`.
- Need verification: `{ "success": true, "status": "go_step_2", "data": { "user_id": 123 } }`.
- Need step 3 only: `{ "success": true, "status": "go_step_3", "data": { "user_id": 123 } }`.

**Step 2 – Verify code**

- **URL:** `POST {baseUrl}register/step/2`
- **Body:** `{ "user_id": "123", "code": "123456" }`
- **Success:** `{ "success": true }`.

**Step 3 – Name & referral**

- **URL:** `POST {baseUrl}register/step/3`
- **Body:** `{ "user_id": "123", "full_name": "John Doe", "referral_code": "" }`
- **Success:** `{ "success": true, "data": { "token": "..." } }`.

**Action:** Implement the three register steps. Ensure step 1 returns `user_id` and `status` when verification or step 3 is required; step 3 must return `data.token` for auto-login.

---

## 5. Forget password

- **URL:** `POST {baseUrl}forget-password`
- **Body (email):** `{ "type": "email", "email": "user@example.com" }`
- **Body (phone):** `{ "type": "mobile", "country_code": "+1", "mobile": "1234567890" }`
- **Success:** `{ "success": true, "message": "..." }`. App shows success message.

**Action:** Implement forget-password (e.g. send reset link to email or SMS code). Response format can follow the app’s `ErrorHandler.success` expectation (message in response).

---

## 6. Social login (Google / Facebook)

- **Google:** `POST {baseUrl}google/callback`  
  Body: `{ "email": "...", "name": "...", "id": "<google_id_token_or_access_token>" }`  
  Success: `{ "data": { "token": "..." } }` (app also checks status 200).

- **Facebook:** `POST {baseUrl}facebook/callback`  
  Body: `{ "id": "<access_token>", "name": "...", "email": "..." }`  
  Success: `{ "success": true, "data": { "token": "..." } }`.

**Action:** Backend should validate the social token, find or create user, return the same `data.token` format as login.

---

## 7. Config endpoint (required for app behavior)

- **URL:** `GET {baseUrl}config`
- **Success (200):** `{ "data": { ... } }`  
  App stores this in `PublicData.apiConfigData`. Used for:
  - `register_method`: `"email"` or `"phone"` (drives login/register UI).
  - `show_google_login_button`, `show_facebook_login_button`: show/hide social buttons.
  - `showOtherRegisterMethod`: show email/phone toggle on login and register.
  - `selectRolesDuringRegistration`: list of roles (e.g. user, teacher, organization) during signup.
  - `currency`, `multi_currency`, `currency_position`, `currency_decimal`: pricing display.
  - `referralSettings.status`: referral feature.
  - `course_notes_attachment`, `allow_instructor_delete_content`, etc.

**Action:** Implement `GET config` returning a JSON object that includes at least `register_method`, social login flags, and any feature flags the app checks (see grep for `apiConfigData` in the app).

---

## 8. HTTP behavior summary

- **Unauthorized (401):** App redirects to Login and clears back stack for `httpGet`, `httpPost`, `httpPut`, `httpDelete` when `isRedirectingStatusCode` is true (default).
- **Maintenance:** If `GET` response body has `status: 'maintenance'`, app can show maintenance page (used for featured-courses).
- **IP restriction:** If response has `status: 'restriction'`, app can show IP empty state (see `http_handler.dart`).

**Action:** Backend should return 401 for invalid/expired token on protected routes; use consistent JSON error shape so `ErrorHandler` can show messages.

---

## 9. Checklist to work with the backend

- [ ] Set `constants.dart` → `dommain` (and optionally `baseUrl`) to your backend base URL.
- [ ] Implement `GET config` and populate `register_method`, social login flags, and currency/feature flags.
- [ ] Implement `POST login` with `username` (email or full phone) and `password`; return `data.token`.
- [ ] Implement `POST register/step/1` (email and phone), optional step 2 and step 3; return `user_id`, `status`, and finally `data.token` from step 3.
- [ ] Implement `POST forget-password` (email or mobile).
- [ ] If using social login: implement `POST google/callback` and `POST facebook/callback`; return `data.token`.
- [ ] Ensure all protected routes accept `Authorization: Bearer <token>` and return 401 when token is invalid or expired.
- [ ] Add CORS and, if needed, ngrok/network config so the app can reach the backend (e.g. from device/emulator).
- [ ] Create at least one user (via backend admin or register API) and test login with email/password (and phone if you use phone registration).

---

## 10. Quick reference – Auth endpoints

| Action | Method | Endpoint | Body (key parts) |
|--------|--------|----------|-------------------|
| Config | GET | `config` | — |
| Register config | GET | `config/register/{role}` | — |
| Login | POST | `login` | `username`, `password` |
| Google | POST | `google/callback` | `email`, `name`, `id` |
| Facebook | POST | `facebook/callback` | `id`, `name`, `email` |
| Register step 1 | POST | `register/step/1` | email: `email`, `password`, `password_confirmation`; phone: `country_code`, `mobile`, `password`, `password_confirmation` |
| Verify code | POST | `register/step/2` | `user_id`, `code` |
| Register step 3 | POST | `register/step/3` | `user_id`, `full_name`, `referral_code` |
| Forget password | POST | `forget-password` | email: `type`, `email`; phone: `type`, `country_code`, `mobile` |
| Logout | POST | `logout` | — (with Bearer token) |

Use this guide to implement or verify your FKM LMS backend so login, signup, and all listed features work correctly with the mobile app.
