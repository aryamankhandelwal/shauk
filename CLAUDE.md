# Shauk — Architecture & Coding Conventions

## What is Shauk
TikTok-style occasion wear discovery app for the Indian diaspora. Users describe an occasion; the app finds and presents outfit cards to swipe through.

## Three Codebases

| Repo | Purpose | Hosting |
|------|---------|---------|
| `shauk/` | SwiftUI iOS app (this repo) | App Store |
| `shauk-api/` | Next.js 14 REST API | Vercel free tier |
| `shauk-screenshot/` | Puppeteer screenshot microservice | Render free tier |

The iOS app communicates with the backend **exclusively via REST API**. No business logic belongs in the iOS app that should live in the backend.

## iOS App Stack
- SwiftUI, iOS 16+ minimum
- Swift Package Manager for dependencies
- Supabase Swift SDK (`supabase-swift` v2.x) for auth + database
- Anonymous auth — no login required
- `async/await` throughout; no Combine

## Folder Structure
```
shauk/
├── Theme/
│   └── DesignSystem.swift     — all Color, Font, Spacing, Animation tokens
├── Models/
│   └── UserProfile.swift      — Codable model matching Supabase users table
├── Services/
│   ├── SupabaseService.swift  — anon auth + CRUD; singleton
│   └── APIService.swift       — REST calls to shauk-api; singleton
├── ViewModels/
│   └── OnboardingViewModel.swift
└── Views/
    ├── Onboarding/            — 4 onboarding screens + container
    └── (Home, Feed, Saved, Profile added in later phases)
```

## Design System
All visual tokens live in `Theme/DesignSystem.swift`. **Never hardcode a colour, font, or spacing value in a view.** Always reference a token.

Fonts: Playfair Display (headings) + DM Sans (body). Both must be bundled as custom fonts.

Theme: the app ships with Light mode as default. Dark mode is toggled in Profile. Theme is stored in `UserDefaults` under key `"theme"` and injected as `\.appTheme` via SwiftUI environment.

Feed screen is **always dark** regardless of theme setting.

## Supabase
- Anonymous auth only (Phase 1). UUID is stored in `UserDefaults` under `"supabaseUserId"`.
- All user data lives in the `users` table, keyed by auth UID.
- Row Level Security is enabled — users can only access their own row.
- Secrets live in `Secrets.swift` (gitignored). Copy `Secrets.example.swift` → `Secrets.swift` and fill in values.

## Coding Conventions
- Views are dumb — no business logic, no direct Supabase/API calls
- ViewModels are `@MainActor ObservableObject`; one per screen/flow
- Services are singletons accessed via `ServiceName.shared`
- `async throws` for all network calls; callers handle errors
- No force-unwraps (`!`) except in fatalError/precondition contexts
- Measurement validation ranges live in `MeasurementField` enum, not in views
- All string literals that appear in the UI are defined as constants (not inline)

## Environment Variables / Secrets
iOS secrets → `Secrets.swift` (gitignored)
API secrets → `.env.local` in `shauk-api/` (gitignored)
Screenshot secrets → `.env` in `shauk-screenshot/` (gitignored)

Never commit any file containing real keys.

## Phase Roadmap
- Phase 1 ✓ — Onboarding + Supabase persistence
- Phase 2 — Home screen + search pipeline (Gemini + Google CSE + Puppeteer)
- Phase 3 — Swipe feed with gestures
- Phase 4 — Saved items grid
