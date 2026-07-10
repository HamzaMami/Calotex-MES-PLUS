# Calotex MES App - Project State

## Project Overview
**Calotex MES** is an Industrial/Manufacturing Manufacturing Execution System (MES) application built with **Flutter** in `frontend/` and a **TypeScript/Node.js** backend in `backend/`.

## Architecture

### Frontend (Flutter)
- Root path: `frontend/`
- **Clean Architecture** implementation with three layers:
  - **Core** - Shared infrastructure (HTTP client, constants, errors, services)
  - **Features** - Feature modules organized by domain
  - **Main** - App entry point and routing

- **Key Dependencies**:
  - State Management: `flutter_bloc`
  - HTTP: `dio` with authentication interceptors
  - Security: `flutter_secure_storage`, `shared_preferences`
  - UI: Material Design 3, Google Fonts

### Backend (TypeScript/Node.js)
- **Express.js** REST API with:
  - CORS enabled
  - JSON body parsing
  - Error handling middleware
  - Health check endpoint

- **Current Modules**:
  - **Auth** - Complete authentication system (controllers, DTOs, services, repositories, routes)
  - **Users** - User management module
  - **Database** - PostgreSQL connection setup
  - **Config** - Environment configuration

- **Key Dependencies**:
  - PostgreSQL: `pg`
  - JWT: `jsonwebtoken`
  - Password hashing: `bcrypt`
  - Validation: `joi`, `zod`
  - Email: `nodemailer`
  - File uploads: `multer`

## Current Status

### ✅ Completed
- Backend server setup with Express
- Authentication module (login, register, token refresh)
- HTTP client with authentication interceptors
- Clean architecture structure
- Database connection layer
- Complete backend MES modules (Products, Manufacturing, Events, Inventory) with PostgreSQL tables

### 🔐 Auth & Security Hardening (Latest Pass)
- **Access + Refresh Tokens**: Backend now issues a short-lived access token (15m) and a long-lived refresh token (7d) with separate secrets. Login returns `{ access_token, refresh_token, expires_in, token_type, user }`.
- **New Endpoints**: `POST /api/auth/refresh` (token rotation) and `POST /api/auth/logout`.
- **Env Config (`src/config/env.ts`)**: Centralized, fail-fast validation of required env vars; rejects the weak default `JWT_SECRET` in production.
- **Security Middleware**: `helmet`, CORS allowlist (`CORS_ORIGINS`), and rate limiting on `/api/auth` (20 req / 15 min / IP).
- **DB Hardening**: Connection pool tuning, `pool.on('error')` handler, optional SSL, startup connectivity check, and graceful shutdown (SIGINT/SIGTERM).
- **Fixes**: Removed password-leaking debug log; auth middleware verifies via env-backed helper; frontend `AuthInterceptor` rewritten with a correct Completer-based refresh queue (concurrent 401s wait for a single refresh and retry); fixed `LoginResponseModel.toString()` crash.
- **New env vars**: `NODE_ENV`, `DB_SSL`, `JWT_REFRESH_SECRET`, `JWT_ACCESS_EXPIRES_IN`, `JWT_ACCESS_EXPIRES_IN_SECONDS`, `JWT_REFRESH_EXPIRES_IN`, `CORS_ORIGINS` (see `backend/.env.example`).

### 🚧 In Progress / Known Issues
- **Frontend Integration**: Dashboard currently uses mock data; needs to be hooked up to the new backend APIs.
- **Frontend Routing**: Some routes use placeholder widgets (Phase 15/17 implementation)
- **Stateless Logout**: Logout is currently client-side (clears tokens; server acks). Server-side refresh-token revocation to be added with the DB/migration foundation.
- **Validation**: Both Joi and Zod are still in use; to be standardized on one library in the next pass.
- **No Migrations Yet**: Schema is managed via raw SQL scripts; a migration tool is planned.

### 📁 Project Structure

```
calotex_app/
├── backend/
│   ├── src/
│   │   ├── app.ts          # Express app setup
│   │   ├── index.ts        # Server entry point
│   │   ├── modules/
│   │   │   ├── auth/       # Complete auth module
│   │   │   ├── users/      # User management module
│   │   │   ├── products/   # Product maturity tracking
│   │   │   ├── manufacturing/# Active orders and volume
│   │   │   ├── events/     # Schedule calendar events
│   │   │   └── inventory/  # Raw materials and stock
│   │   ├── config/
│   │   ├── database/
│   │   └── shared/
│   └── package.json
├── frontend/
│   ├── lib/
│   │   ├── core/           # Shared infrastructure
│   │   ├── features/
│   │   └── main.dart       # App entry point
│   ├── assets/
│   └── pubspec.yaml
└── pubspec.yaml            # Removed from root; Flutter now lives in frontend/
```

## Next Steps / Recommendations

1. **Backend Foundation (next pass)**
   - Add an `asyncHandler` wrapper + typed error classes and a single error middleware to remove repetitive controller try/catch.
   - Standardize on one validation library (Joi or Zod).
   - Adopt a migration tool and add indexes (`users.email`, FKs, `events.event_date`).
   - Add pagination to list endpoints; consider a `/dashboard` aggregate endpoint.

2. **Frontend Foundation (next pass)**
   - Introduce `get_it` service locator (dependency already present) instead of manual wiring in `main.dart`.
   - Adopt `go_router` with an auth-guard redirect.
   - Move `baseUrl` to `--dart-define` / flavors (dev/staging/prod; note Android emulator needs `10.0.2.2`).

3. **Complete Missing Features**
   - Replace placeholder widgets with real screens and hook the dashboard to live APIs.

4. **Testing**
   - Add unit tests for both frontend and backend; integration tests for API endpoints.

## Technical Debt / Improvements

- ✅ Env config validation + fail-fast (done)
- ✅ Security middleware: helmet, CORS allowlist, rate limiting (done)
- ✅ Access/refresh token flow + interceptor fix (done)
- Add structured request logging (e.g. morgan/pino)
- Add ESLint/Prettier (backend) and stricter Dart lints (frontend)
- Commit lock files for reproducible builds; track migration/seed scripts in VCS
- Implement proper error/loading/empty states across UI

---
*Last updated: Based on project exploration*