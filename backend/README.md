# HomeNetworkAssistant Backend

ASP.NET Core Web API backend for `home_network_assistant`.

## Stack

- ASP.NET Core Web API
- EF Core
- SQLite
- Swagger

## Projects

- `HomeNetworkAssistant.Api` - main API
- `HomeNetworkAssistant.Api.Tests` - service-level tests

## Run

```bash
cd backend/HomeNetworkAssistant.Api
dotnet run
```

Swagger UI is available in development mode at `/swagger`.

## Test

```bash
cd backend/HomeNetworkAssistant.Api.Tests
dotnet test
```

## Seed users

- `admin` / `admin123`
- `user` / `user123`

## User context

Mutating endpoints and role-sensitive reads use the `X-User-Login` header.

Example:

```bash
curl -X POST http://localhost:5000/api/projects/1/devices \
  -H "Content-Type: application/json" \
  -H "X-User-Login: user" \
  -d '{
    "name": "New Device",
    "type": "sensor",
    "ipAddress": "192.168.1.250",
    "macAddress": "AA:BB:CC:DD:EE:FA",
    "connectionType": "wifi",
    "room": "Кухня",
    "status": "active",
    "signalStrength": 70,
    "speedMbps": 100,
    "description": "Created from curl",
    "isGuest": false,
    "requiresStaticIp": false
  }'
```

## Main routes

- `POST /api/auth/login`
- `GET /api/users`
- `GET /api/projects`
- `POST /api/projects`
- `GET /api/projects/{projectId}`
- `GET /api/projects/{projectId}/devices`
- `POST /api/projects/{projectId}/devices`
- `PUT /api/devices/{deviceId}`
- `POST /api/devices/{deviceId}/favorite`
- `POST /api/devices/{deviceId}/trash`
- `POST /api/devices/{deviceId}/restore`
- `GET /api/projects/{projectId}/requests`
- `POST /api/requests/{requestId}/approve`
- `POST /api/requests/{requestId}/reject`
- `GET /api/projects/{projectId}/notifications`
- `POST /api/notifications/{notificationId}/read`
- `GET /api/projects/{projectId}/router-settings`
- `PUT /api/projects/{projectId}/router-settings`
