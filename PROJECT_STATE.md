# Calotex MES App - Project State

## Project Overview
**Calotex MES** is an Industrial/Manufacturing Execution System (MES) application built with **Flutter** in `frontend/` and a **TypeScript/Node.js** backend in `backend/`.

## Architecture

### Frontend (Flutter)
- Root path: `frontend/`
- **Clean Architecture** implementation with three layers:
  - **Core** - Shared infrastructure (HTTP client, constants, errors, services, dependency injection, stubs)
  - **Features** - Feature modules organized by domain (Auth, Dashboard, Admin)
  - **Main** - App entry point with `GetIt` dependency injection

- **Key Dependencies**:
  - State Management: `flutter_bloc`
  - Dependency Injection: `get_it`
  - HTTP: `dio` with authentication interceptors
  - Security: `flutter_secure_storage`, `shared_preferences`
  - UI: Material Design 3, Google Fonts

### Backend (TypeScript/Node.js)
- **Express.js** REST API with:
  - CORS enabled
  - JSON body parsing
  - Centralized `asyncHandler` error handling
  - Rate limiting & security middleware (`helmet`)
  - Health check endpoint

- **Current Modules**:
  - **Auth** - Complete authentication system (controllers, DTOs, services, repositories, routes)
  - **Users** - User management module
  - **Products** - Product maturity tracking module
  - **Manufacturing** - Manufacturing orders and volume module
  - **Events** - Schedule calendar events module
  - **Inventory** - Raw materials and stock module
  - **Roles & Permissions** - RBAC authorization module
  - **Database** - PostgreSQL connection setup & migration scripts

- **Key Dependencies**:
  - PostgreSQL: `pg`
  - JWT: `jsonwebtoken`
  - Password hashing: `bcrypt`
  - Validation: `zod`, `joi`
  - Email: `nodemailer`

---

## Current Status

### ✅ Completed
- Express REST API server setup with security headers (`helmet`) & rate limiting
- Complete authentication module (login, register, token refresh rotation)
- Access + Refresh token flow with frontend Dio interceptors
- MES modules (Products, Manufacturing, Events, Inventory, Users, Roles & Permissions)
- Centralized `asyncHandler` error handling wrapper & sanitized global error middleware
- SQL column whitelisting on dynamic UPDATE operations to eliminate SQL injection risks
- Pagination (`page`, `limit`) on all backend list endpoints and repositories
- PostgreSQL performance index migration script (`01_add_indexes.sql`)
- Frontend `GetIt` service locator container in `frontend/lib/core/di/injection_container.dart`
- Theme color consolidation across `LoginPage` and `RegisterPage` using `AppTheme`

### 🧹 Cleaned & Maintained (Latest Maintenance Pass)
- **Repository Cleanup**: Removed unreferenced duplicate SQL schemas (`backend/src/config/schema.sql`).
- **Transpiled Artifact Removal**: Cleaned up transpiled `.js`, `.js.map`, `.d.ts`, and `.d.ts.map` files out of `backend/scripts/` to maintain clean source control.
- **Test File Cleanup**: Cleared unit/widget test files and platform runner test boilerplate across `frontend/test/`, `frontend/ios/RunnerTests/`, `frontend/macos/RunnerTests/`, and `Calotex Kpi Showcase/test/`.
- **Database Reset**: Cleared all sample/dashboard data from PostgreSQL tables (`events`, `manufacturing_orders`, `products`) with `RESTART IDENTITY CASCADE`.

---

### 🚧 In Progress / Next Steps

1. **Routing Enhancement**: Adopt `go_router` for declarative routing with top-level Auth Guard redirects.
2. **Environment Defines**: Move `baseUrl` in frontend to `--dart-define` / flavors (dev/staging/prod).
3. **Validation Standardization**: Consolidate remaining Joi validation schemas into Zod.
4. **Export Planning Feature**: Finalize requirements and implementation for Excel-based Export Planning with Calendar Week (KW) logic & strict RBAC authorization.

---
*Last updated: Workspace Cleanup & Dashboard Data Reset Completed*