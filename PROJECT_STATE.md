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

### 🚧 In Progress / Known Issues
- **Frontend Integration**: Dashboard currently uses mock data; needs to be hooked up to the new backend APIs.
- **Frontend Routing**: Some routes use placeholder widgets (Phase 15/17 implementation)

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

1. **Complete Missing Features**
   - Implement remaining business features (production, inventory, quality control, etc.)
   - Add routing for all screens in the frontend

2. **Database Schema**
   - Define PostgreSQL schema for MES data models
   - Create migration scripts

3. **API Endpoints**
   - Implement CRUD endpoints for production orders, inventory, etc.
   - Add business logic and validation

4. **Frontend Screens**
   - Replace placeholder widgets with actual UI screens
   - Implement navigation between screens

5. **Testing**
   - Add unit tests for both frontend and backend
   - Implement integration tests for API endpoints

## Technical Debt / Improvements

- Consider adding more interceptors (logging, error tracking)
- Implement proper error handling and user feedback
- Add loading states and error states to UI
- Consider adding more features to the backend (validation, caching, rate limiting)

---
*Last updated: Based on project exploration*