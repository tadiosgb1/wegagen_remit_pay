# HTTP-Only Cookie Authentication for Flutter Mobile Apps

## Overview

Your backend uses HTTP-only cookies for authentication with this configuration:
```javascript
res.cookie('access_token', token, {
  httpOnly: true,
  secure: false, // localhost only
  sameSite: 'lax',
  maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
});
```

## Solution Implementation

### 1. Dependencies Added

Added to `pubspec.yaml`:
```yaml
dio_cookie_manager: ^3.1.1
cookie_jar: ^4.0.8
```

### 2. API Service Changes

**Key Changes Made:**
- Added `CookieJar` for persistent cookie storage
- Configured Dio with `CookieManager` interceptor
- HTTP-only cookies are automatically sent with requests
- Cookies persist across app sessions on mobile

**How it works:**
```dart
// Initialize cookie jar for mobile
final appDocDir = await getApplicationDocumentsDirectory();
final cookiePath = "${appDocDir.path}/.cookies/";
_cookieJar = PersistCookieJar(
  ignoreExpires: true,
  storage: FileStorage(cookiePath),
);

// Add cookie manager to Dio
_dio.interceptors.add(CookieManager(_cookieJar));
```

### 3. Authentication Flow

**Login Process:**
1. Mobile app sends login credentials to `/login`
2. Backend validates and sets HTTP-only cookie in response
3. Cookie manager automatically saves the cookie
4. Future requests automatically include the cookie

**Logout Process:**
1. Call `/logout` endpoint to invalidate server-side session
2. Clear local cookies using `clearCookies()`
3. Remove local user data

### 4. Key Benefits

- **Security**: Cookies can't be accessed by malicious JavaScript
- **Automatic**: No manual token management needed
- **Persistent**: Cookies survive app restarts
- **Cross-platform**: Works on both mobile and web

### 5. Backend Requirements

Your backend should:
```javascript
// Login endpoint - set cookie
app.post('/login', (req, res) => {
  // ... validate credentials
  const token = generateToken(user);
  
  res.cookie('access_token', token, {
    httpOnly: true,
    secure: false, // set to true in production with HTTPS
    sameSite: 'lax',
    maxAge: 30 * 24 * 60 * 60 * 1000,
  });
  
  res.json({ success: true, user: userData });
});

// Logout endpoint - clear cookie
app.post('/logout', (req, res) => {
  res.clearCookie('access_token');
  res.json({ success: true });
});

// Protected routes - validate cookie
app.use('/api/protected', (req, res, next) => {
  const token = req.cookies.access_token;
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  
  // Validate token...
  next();
});
```

### 6. Mobile vs Web Differences

**Mobile (this implementation):**
- Uses `PersistCookieJar` for cookie storage
- Cookies stored in app documents directory
- Works with both HTTP and HTTPS

**Web:**
- Browser handles cookies automatically
- No additional cookie jar needed
- Subject to browser cookie policies

### 7. Testing

To verify cookie authentication is working:
```dart
// Check if cookies are being sent
final cookies = await ApiService().getCookies('http://your-backend-url');
print('Cookies: $cookies');

// Make authenticated request
final response = await ApiService().get('/api/protected-endpoint');
```

### 8. Troubleshooting

**Common Issues:**
1. **Cookies not being sent**: Check if cookie jar is properly initialized
2. **Login not persisting**: Verify backend sets cookies correctly
3. **CORS issues**: Ensure backend allows credentials in CORS config

**Debug Commands:**
```dart
// Clear all cookies (for testing)
await ApiService().clearCookies();

// View stored cookies
final cookies = await ApiService().getCookies(baseUrl);
print('Stored cookies: $cookies');
```

## Next Steps

1. Run `flutter pub get` to install new dependencies
2. Test login/logout flow
3. Verify cookies persist across app restarts
4. Update backend CORS settings if needed:
   ```javascript
   app.use(cors({
     credentials: true,
     origin: ['http://localhost:3000', 'your-mobile-app-origin']
   }));
   ```

The implementation automatically handles cookie storage and transmission, making your mobile app work seamlessly with HTTP-only cookie authentication.