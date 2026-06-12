# Backend CORS Fix for HTTP-Only Cookie Authentication

## Issue Identified
Your backend is properly set up for HTTP-only cookies, but the CORS configuration only allows Vue.js origins. Flutter web and mobile apps need additional origins to work with HTTP-only cookies.

## Current Backend Status ✅
- ✅ Cookie parser enabled
- ✅ Login sets HTTP-only cookie: `res.cookie('access_token', token, {...})`
- ✅ Auth guard reads from `request.cookies?.access_token`
- ❌ CORS limited to Vue.js only

## Required Fix: Update backend/src/main.ts

Replace the existing CORS configuration:

```typescript
// REPLACE THIS:
app.enableCors({
  origin: ['http://localhost:3000', 'http://10.195.49.18:3000'], // Vue app URL
  credentials: true,
});

// WITH THIS:
app.enableCors({
  origin: [
    // Vue.js frontend (existing)
    'http://localhost:3000', 
    'http://10.195.49.18:3000',
    
    // Flutter web development
    'http://localhost:8080',
    'http://localhost',
    'http://127.0.0.1:8080',
    
    // Flutter mobile (Android WebView and file protocols)
    'file://',
    'https://appassets.androidplatform.net',
    'capacitor://localhost',
    'ionic://localhost',
    
    // Development - allow any origin for testing
    true
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization', 
    'X-API-Key',
    'Accept',
    'Origin',
    'User-Agent'
  ],
});
```

## Additional Backend Fixes

### 1. Fix Cookie Configuration in users.service.ts

Update the cookie configuration for better cross-platform support:

```typescript
// In login method, update cookie settings:
res.cookie('access_token', token, {
  httpOnly: true,
  secure: false,        // Keep false for development
  sameSite: 'lax',      // Change from false to 'lax' for better browser support
  maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
  path: '/',            // Add explicit path
});
```

### 2. Add Logout Endpoint

Add this to your users.controller.ts:

```typescript
@Post('logout')
@HttpCode(HttpStatus.OK)
logout(@Res({ passthrough: true }) res: Response) {
  res.clearCookie('access_token', {
    httpOnly: true,
    secure: false,
    sameSite: 'lax',
    path: '/',
  });
  return { message: 'Logged out successfully' };
}
```

### 3. Add Health Endpoint (if missing)

Add to app.controller.ts:

```typescript
@Get('health')
getHealth() {
  return { status: 'ok', timestamp: new Date().toISOString() };
}
```

## After Making Changes

1. **Stop backend server**: `Ctrl+C`
2. **Restart backend**: `npm run start:dev`
3. **Test with Flutter app**

## Testing Commands

After restarting backend, test with:

```bash
# Test CORS preflight
curl -X OPTIONS http://10.195.49.18:3001/users/login \
  -H "Origin: http://localhost" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type"

# Should return Access-Control-Allow-Credentials: true
```

## Flutter App Configuration

The Flutter app is already properly configured with:
- ✅ Cookie jar for mobile persistence
- ✅ Web adapter with `withCredentials: true`
- ✅ Platform-specific authentication handling

## Production Considerations

For production deployment:
1. Change `secure: true` for HTTPS
2. Set specific origins instead of `true`
3. Add domain restrictions
4. Enable rate limiting

## Common Issues & Solutions

**Issue**: "CORS error" on Flutter web
**Solution**: Backend needs the updated CORS origins

**Issue**: Cookies not persisting on mobile
**Solution**: Check cookie jar initialization (already fixed in Flutter app)

**Issue**: 401 Unauthorized after login
**Solution**: Verify cookie `sameSite` setting matches request origin

**Issue**: Login works but protected routes fail
**Solution**: Ensure `withCredentials: true` on all API calls (already implemented)

## Verification Steps

1. Login from Flutter web - should work without errors
2. Login from Android app - should persist across app restarts
3. Access protected endpoints - should work automatically
4. Logout - should clear cookies and require re-login

The Flutter app is already properly configured for HTTP-only cookies. The backend CORS fix is the missing piece.