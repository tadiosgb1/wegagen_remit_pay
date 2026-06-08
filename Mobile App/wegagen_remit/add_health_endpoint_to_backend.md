# Add Health Endpoint to Backend

To fix the health check connection issue, add this to your backend:

## Option 1: Add to AppController (Recommended)

In `backend/src/app.controller.ts`, add:

```typescript
import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  // Add this health check endpoint
  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'Wegagen Remit API',
      version: '1.0.0'
    };
  }
}
```

## Option 2: Create Separate Health Controller

Create `backend/src/health/health.controller.ts`:

```typescript
import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  check() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'Wegagen Remit API'
    };
  }
}
```

Then add to `app.module.ts`:

```typescript
import { HealthController } from './health/health.controller';

@Module({
  controllers: [AppController, HealthController, /* other controllers */],
  // ... rest of module
})
```

## After Adding:

1. Restart your backend server
2. Test: `curl http://10.195.49.18:3001/health`
3. Should return: `{"status":"ok","timestamp":"...","service":"Wegagen Remit API"}`

This will fix the connection health checks in the Flutter app.