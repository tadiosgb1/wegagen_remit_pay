# HTTP-Only Cookie Authentication Implementation

## Overview
This implementation enables secure authentication using HTTP-only cookies with `withCredentials: true` for web requests, while maintaining backward compatibility for mobile apps using Bearer tokens.

## Key Changes Made

### 1. ApiService Updates (`lib/services/api_service.dart`)

- **Added browser client import**: Added conditional import for `BrowserClient` for web platform
- **Updated client initialization**: 
  - Web: Uses `BrowserClient` with `withCredentials = true` to enable HTTP-only cookie support
  - Mobile: Maintains existing behavior with `IOClient` and SSL certificate handling
- **Updated headers**: 
  - Web: Relies on HTTP-only cookies for authentication (no Authorization header)
  - Mobile: Continues using Bearer token in Authorization header

### 2. AuthService Updates (`lib/services/auth_service.dart`)

- **Platform-aware token storage**:
  - Web: Only stores user data and login state, relies on HTTP-only cookies for tokens
  - Mobile: Stores tokens in SharedPreferences as before
- **Updated authentication check**:
  - Web: Checks login state (s