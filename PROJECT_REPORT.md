# Dating App Project Report

## Overview
This project is a Flutter dating application built with Flutter 3 / Dart 3. It uses GetX for state management, routing, and dependency injection, with Dio for backend networking. The app combines a modern swipe-based discovery flow, auth management, and an API-driven service architecture.

## Project Structure
- `lib/main.dart` — app entry point, initializes `AuthService`, and starts `GetMaterialApp`.
- `lib/app/app_routes.dart` — route names and GetX page definitions.
- `lib/app/app_bindings.dart` — registers services and controllers with GetX DI.
- `lib/network/api_client.dart` — shared Dio client, interceptors, and retry handling.
- `lib/network/api_endpoints.dart` — backend endpoint definitions and URL helpers.
- `lib/services/` — business logic and API wrappers (`AuthService`, `UserService`, `SwipeService`, `ChatService`).
- `lib/controllers/` — GetX controllers that manage state and user interaction.
- `lib/screens/` — UI screens for onboarding, auth, home, swipe, chat, profile, etc.
- `lib/utils/constants.dart` — app constants, API config, storage keys, and UI values.
- `pubspec.yaml` — dependencies and package configuration.

## Architecture
The app uses a layered architecture with clear separation of concerns:

1. UI Layer
   - `lib/screens/` and `lib/widgets/`
   - Displays app content and handles user input.

2. Controller Layer
   - `lib/controllers/`
   - Uses GetX controllers to manage reactive state and coordinate service calls.

3. Service Layer
   - `lib/services/`
   - Handles business logic, API calls, token storage, and response handling.

4. Network Layer
   - `lib/network/api_client.dart`
   - Central HTTP client built with Dio, with interceptors and retry logic.

5. Data/Model Layer
   - `lib/models/` defines request/response objects.
   - `lib/data/mock_data.dart` provides sample profiles for demo flows.

6. Dependency Injection
   - `lib/app/app_bindings.dart` ensures services and controllers are initialized once.
   - `main.dart` uses `GetMaterialApp` and `initialBinding: AppBindings()`.

## App Flow
1. App starts in `lib/main.dart`.
2. `AuthService.initialize()` loads saved tokens from `SharedPreferences`.
3. The app launches at `AppRoutes.onboarding`.
4. User can navigate to `/login` or `/signup`.
5. After successful login/signup, navigation goes to `/home`.
6. From `HomeScreen`, the app can open swipe discovery, match lists, chat, or profile screens.
7. `SwipeScreen` provides the core swipe/discovery flow.

## Navigation and Routing
Defined routes in `lib/app/app_routes.dart`:
- `/onboarding`
- `/login`
- `/signup`
- `/home`
- `/swipe`
- `/matches`
- `/chat`
- `/chat/:id`
- `/profile`
- `/profile/edit`
- `/settings`
- `/notifications`
- `/splash`

Currently registered pages in `AppRoutes.pages` include onboarding, login, signup, and home. Additional routes are defined but not yet added as GetPages.

## API Backend
Backend base URL:
- `https://new-dating-app-backend.vercel.app`

### Auth Endpoints
- `POST /users/register`
- `POST /users/login`
- `GET /users/otp/email/{email}`
- `POST /users/otp/email/validate`
- `POST /auth/logout`
- `POST /auth/refresh-token`

### User Profile Endpoints
- `GET /users/:id`
- `PUT /users/:id`
- `DELETE /users/:id`
- `POST /users/upload-photo`
- `DELETE /users/delete-photo`
- `GET /users/preferences`
- `PUT /users/preferences`

### Swipe & Match Endpoints
- `GET /profiles`
- `GET /profiles/:id`
- `GET /users/suggestions`
- `POST /profiles/like`
- `POST /profiles/super-like`
- `POST /profiles/pass`
- `POST /profiles/unlike`
- `GET /matches`
- `GET /matches/:id`
- `POST /matches/accept`
- `POST /matches/reject`
- `POST /matches/unmatch`
- `GET /matches/top`
- `GET /profiles/nearby`

### Chat Endpoints
- `GET /conversations`
- `GET /conversations/:id`
- `GET /conversations/:conversationId/messages`
- `POST /messages`
- `POST /messages/upload`
- `POST /conversations/:conversationId/read`
- `DELETE /messages/:id`
- `POST /typing`
- `POST /messages/report`

### Blocking Endpoints
- `POST /users/:id/block`
- `POST /users/:id/unblock`
- `GET /users/blocked`

## API Client Behavior
- Uses Dio with base URL and 30-second timeout.
- Adds bearer token headers when user is authenticated.
- Supports multiple HTTP methods and file uploads.
- Logs responses and errors.
- Implements retry attempts up to 3 times for network failures.

## Key Features Implemented
- GetX-based navigation and dependency injection.
- Authentication flow with token persistence.
- Onboarding, login, signup, and home screen scaffolding.
- Swipe discovery UI using `swipable_stack`.
- Backend API contract defined with `ApiEndpoints`.
- Central app constants and storage keys in `AppConstants`.
- Shared preferences support for auth token storage.
- Reusable services for auth, user, swipe, and chat.

## Packages Used
- `get`
- `dio`
- `shared_preferences`
- `swipable_stack`
- `image_picker`
- `geolocator`
- `permission_handler`
- `country_code_picker`
- `cached_network_image`
- `google_fonts`
- `flutter_screenutil`
- `logger`
- `flutter_svg`
- `intl`

## Current Status
- Auth service and network layer are established.
- Core app structure and navigation are set up.
- Swipe screen exists, but it may use mock/demo data in some flows.
- Not all defined routes are wired into `AppRoutes.pages`.
- Backend integration is partially complete; additional screens and flows still need live API hookup.

## Recommended Next Steps
1. Register all defined routes in `AppRoutes.pages`.
2. Replace mock data with real API responses in swipe, user, and chat screens.
3. Complete profile edit, matches, chat detail, and settings backend integration.
4. Add refresh-token handling and improved error UI.
5. Implement unit tests for services and controllers.

---

> Generated from current project files in `lib/`, `pubspec.yaml`, and app configuration sources.
Main endpoints defined in `lib/network/api_endpoints.dart` include:

### Authentication
- `POST /users/register` — create user account.
- `POST /users/login` — login with email/password.
- `GET /users/otp/email/{email}` — send email OTP.
- `POST /users/otp/email/validate` — verify OTP.
- `POST /auth/logout` — logout.
- `POST /auth/refresh-token` — refresh auth token.

### User Profile
- `GET /users/:id` — get user profile.
- `PUT /users/:id` — update profile.
- `DELETE /users/:id` — delete account.
- `POST /users/upload-photo` — upload profile photo.
- `DELETE /users/delete-photo` — delete photo.
- `GET /users/preferences` — fetch preferences.
- `PUT /users/preferences` — update preferences.

### Swipe & Matches
- `GET /profiles` — list profiles.
- `GET /profiles/:id` — profile detail.
- `GET /users/suggestions` — get swipe suggestions.
- `POST /profiles/like` — like a profile.
- `POST /profiles/super-like` — super like a profile.
- `POST /profiles/pass` — pass a profile.
- `POST /profiles/unlike` — unlike a profile.
- `GET /matches` — list matches.
- `GET /matches/:id` — match details.
- `POST /matches/accept` — accept a match.
- `POST /matches/reject` — reject match.
- `POST /matches/unmatch` — unmatch.
- `GET /matches/top` — top matches.
- `GET /profiles/nearby` — nearby profiles.

### Chat
- `GET /conversations` — list conversations.
- `GET /conversations/:id` — conversation details.
- `GET /conversations/:conversationId/messages` — messages in a conversation.
- `POST /messages` — send message.
- `POST /messages/upload` — upload chat media.
- `POST /conversations/:conversationId/read` — mark as read.
- `DELETE /messages/:id` — delete message.
- `POST /typing` — typing indicator.
- `POST /messages/report` — report message.

### Blocking
- `POST /users/:id/block` — block user.
- `POST /users/:id/unblock` — unblock user.
- `GET /users/blocked` — blocked list.

## Networking Details
- `lib/network/api_client.dart` implements a singleton `ApiClient` using Dio.
- Base URL and timeouts are configured from `AppConstants`.
- Request interceptor adds `Authorization: Bearer <token>` header when token exists.
- Response interceptor logs results.
- Error interceptor handles status codes and logs errors.
- Retry interceptor retries on network failures or 408/429 responses up to 3 times.
- `ApiClient` supports GET/POST/PUT/DELETE/PATCH and file upload endpoints.

## Current Implementation Status
- Authentication and signup/login flows are supported in code via `AuthController` and `AuthService`.
- Swipe flow exists and currently uses mock data from `lib/data/mock_data.dart`.
- Home UI and swipe card UI are implemented with sample layout.
- `UserController` currently loads demo user and preferences from mock data.
- Some route names are defined but not all routes are registered in `AppRoutes.pages`.
- The backend API structure is prepared, but several UI actions still rely on demo/mock data.

## Notes
- The app uses GetX for navigation and dependency injection.
- The project combines backend-ready service classes with local demo data to support early UI testing.
- `SharedPreferences` stores auth tokens, user ID, and email for persistent login.
- `AppConstants.baseUrl` points to a live-looking backend host, so the app is largely ready to integrate with the backend.

## Recommended Next Steps
1. Connect the remaining UI screens to the service layer and API endpoints.
2. Complete route registration for swipe, matches, chat, profile edit, settings, and notifications.
3. Replace mock data usage with real API responses in `SwipeController`, `UserController`, and `ChatController`.
4. Add error handling and loading UI states across all screens.
5. Implement token refresh logic in `ApiClient` interceptor.
6. Add unit tests for services, controllers, and networking behavior.

---

Generated from current project files: `lib/main.dart`, `lib/app/app_routes.dart`, `lib/app/app_bindings.dart`, `lib/network/api_client.dart`, `lib/network/api_endpoints.dart`, `lib/services/auth_service.dart`, `lib/services/user_service.dart`, `lib/controllers/`, and `lib/screens/`.