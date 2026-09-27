# Calotex MES App - Project State

## Project Overview
**Calotex MES** is an Industrial/Manufacturing Execution System (MES) application built with **Flutter** in `frontend/` and a **TypeScript/Node.js** backend in `backend/`.

## Architecture

### Frontend (Flutter)
- Root path: `frontend/`
- **Clean Architecture** implementation with three layers:
  - **Core** - Shared infrastructure (HTTP client, constants, errors, services, dependency injection)
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

### ⚡ Code Optimization & Security Pass (Latest Pass)
- **Async Error Wrapper**: Created `src/shared/utils/asyncHandler.ts` and wrapped all controllers, eliminating repetitive try/catch blocks and uncaught promise rejections.
- **SQL Injection Prevention**: Added strict `ALLOWED_*_COLUMNS` Whitelist sets across `product`, `inventory`, `manufacturing_order`, `users`, and `event` repositories.
- **Repository & Controller Pagination**: Added optional `page` and `limit` support to all repository `findAll()` functions, calculating totals and offset query execution.
- **DB Performance Indexes**: Created `src/database/migrations/01_add_indexes.sql` with indexes on `users(email)`, `users(role_id)`, `events(event_date)`, `manufacturing_orders(product_id)`, and `inventory(sku)`.
- **Frontend Dependency Injection**: Configured `GetIt` in `frontend/lib/core/di/injection_container.dart` for clean singleton and factory registration, updating `main.dart`.
- **UI Theme Standardization**: Refactored `LoginPage` and `RegisterPage` to consume `AppTheme` properties directly instead of inline hardcoded hex colors.

---

### 🚧 In Progress / Next Steps

1. **Routing Enhancement**: Adopt `go_router` for declarative routing with top-level Auth Guard redirects.
2. **Environment Defines**: Move `baseUrl` in frontend to `--dart-define` / flavors (dev/staging/prod).
3. **Validation Standardization**: Consolidate remaining Joi validation schemas into Zod.
4. **Testing**: Add unit and integration tests for frontend BLoCs and backend Express endpoints.

---
*Last updated: Code Optimization & Security Pass Completed*