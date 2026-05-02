# Shauk — Architecture & Coding Conventions

> **SESSION START RULE:** At the start of every new session or after /clear, read ONLY this file first. Do NOT scan the three repos until you need a specific file. This file has enough context to begin.

> **MAINTENANCE RULE:** After every 3–4 user prompts that result in meaningful code changes, update the "Recent Changes" section below. Keep it to the last ~5 bullet points; drop old ones. Also update the Phase Roadmap if a phase completes.

---

## What is Shauk
TikTok-style occasion wear discovery app for the Indian diaspora. Users describe an occasion; the app finds and presents outfit cards to swipe through.

---

## Three Repos (local paths)

| Repo | Path | Purpose | Hosting |
|------|------|---------|---------|
| iOS app | `~/aryaman/Projects/shauk/` | SwiftUI client | App Store |
| API | `~/aryaman/Projects/shauk-api/` | Next.js 14 REST API | Vercel free tier |
| Screenshot | `~/aryaman/Projects/shauk-scraper/` | Puppeteer microservice | Render free tier |

The iOS app talks to the backend **exclusively via REST API**. No business logic that belongs in the backend should live in the iOS app.

---

## iOS App — Key Files

```
shauk/
├── Theme/DesignSystem.swift      — Color, Font, Spacing, Animation tokens
├── Models/
│   ├── UserProfile.swift         — Codable; matches Supabase users table
│   └── OutfitCard.swift          — Feed card model (title, imageURL, shopURL, etc.)
├── Services/
│   ├── SupabaseService.swift     — anon auth + CRUD; singleton
│   └── APIService.swift          — REST calls to shauk-api; singleton
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   └── HomeViewModel.swift       — drives feed: search, screenshot fetch, card state
└── Views/
    ├── Onboarding/               — 4 screens + container
    ├── Home/
    │   └── SwipeFeedView.swift   — TikTok swipe feed; always dark
    └── Main/MainTabView.swift    — tab bar host
```

---

## Stack & Conventions

- SwiftUI, iOS 16+, SPM, `async/await` (no Combine)
- Supabase Swift SDK v2.x — anonymous auth only; UUID in `UserDefaults["supabaseUserId"]`
- Views are dumb — no network calls, no business logic
- ViewModels: `@MainActor ObservableObject`; one per screen
- Services: singletons via `ServiceName.shared`; all network calls are `async throws`
- No force-unwraps (`!`) outside `fatalError`/`precondition`
- Never hardcode colour/font/spacing — always use a `DesignSystem` token
- Feed screen is **always dark** regardless of app theme
- App theme (light/dark) stored in `UserDefaults["theme"]`, injected via `\.appTheme`

---

## shauk-api (Next.js 14 — Vercel free tier)

**Path:** `~/aryaman/Projects/shauk-api/`

```
app/api/
├── search/route.ts     — POST; queries Supabase products table, returns OutfitCard list
└── lib/
    ├── classifier.ts   — regex classifier: gender (male/female/kids/unknown) from title+URL
    └── (Gemini + Google CSE logic lives in route.ts)
```

- `POST /api/search` — takes occasion text, queries Supabase `products` table, maps rows → `OutfitCard` shape (brand, name, price, image_url, product_url, source, gender, etc.)
- Gender/kids classification via regex patterns; `SYNC` comment marks patterns shared with scraper
- Supabase accessed via service role key (server-side only)
- 25s function timeout (Vercel free tier limit)

---

## shauk-scraper (Express + Puppeteer — Render free tier)

**Path:** `~/aryaman/Projects/shauk-scraper/`

```
src/
├── index.ts            — Express server; GET /health, GET /search (title search in Supabase)
├── ingest.ts           — CLI: scrapes all three retailers → dedupes → upserts to Supabase
├── types.ts            — shared Item, ItemGender types
├── lib/
│   ├── browser.ts      — Puppeteer browser lifecycle helpers
│   ├── metadata.ts     — extracts garment metadata (color, fabric, embellishments)
│   └── supabase.ts     — Supabase client (service role)
└── scrapers/
    ├── myntra.ts       — scrapes Myntra ethnic wear listings
    ├── nykaa.ts        — scrapes Nykaa Fashion ethnic wear listings
    └── manish.ts       — scrapes Manish Malhotra site
```

- `ingest.ts` is a one-off CLI script (not the server); run manually to refresh the product DB
- Kids products filtered at ingest time via regex + URL segment matching (never enter DB)
- Gender patterns must stay in sync with `shauk-api/app/api/lib/classifier.ts` (marked with `SYNC` comment)
- Render free tier spins down after inactivity; screenshot requests can be slow on cold start

---

## Secrets

| Repo | File | Notes |
|------|------|-------|
| iOS | `Secrets.swift` | gitignored; copy from `Secrets.example.swift` |
| API | `.env.local` | gitignored |
| Scraper | `.env` | gitignored |

Never commit real keys.

---

## Phase Roadmap

- Phase 1 ✓ — Onboarding + Supabase persistence
- Phase 2 ✓ — Home screen + search pipeline (Gemini + Google CSE + Puppeteer)
- Phase 3 ✓ — TikTok-style swipe feed with like/shop actions
- Phase 4 — Saved items grid
- Phase 5 — Profile screen + dark-mode toggle

---

## Recent Changes *(update every ~3–4 prompts)*

- Feed images switched from base64 → `AsyncImage` URL loading (ee0096e)
- Screenshot timeout raised 15s → 25s to match Vercel free-tier execution limit (0cb9b6c)
- Removed 6-card cap; screenshot fetches throttled to 4 concurrent (cf02bb9)
- Feed propagates resolved product URLs; failed cards filtered out (4185057)
- Failed-card UI added; cards no longer stuck on loading state (1b9c0d5)
