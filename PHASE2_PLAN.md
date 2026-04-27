# Phase 2 Implementation Plan: Home Screen + Search Pipeline

## Context
Phase 1 (onboarding + Supabase persistence) is complete. Phase 2 delivers the Home screen, the full backend search pipeline (Gemini → Google CSE → Puppeteer), and the app navigation shell (tabs, profile, saved stub). The design reference is https://api.anthropic.com/v1/design/h/JXWrXJvGvumVpOlagYKFSw?open_file=shauk.html — a complete HTML/CSS/JS mockup of all 4 phases built in Claude Design.

Phase 3 (swipe feed) and Phase 4 (saved grid) are *designed* in the mockup but NOT implemented here. Phase 2 ends with a basic results list view that Phase 3 replaces with the swipe card feed.

---

## Design Summary (from shauk.html)

### Home Screen
- **Header**: "Shauk" logo (Playfair 22pt) left + avatar circle "S" (gradient gold→brown) right
- **Greeting**: Playfair 26pt "What are you\n*dressing up for?*" — the second line is italic in `--accent`
- **Subtext**: DM Sans 13pt t3 "Describe your occasion — we'll find the looks."
- **Prompt box**: `--surface` card, 1.5px `--border`, 20pt radius, box-shadow; label "DESCRIBE YOUR OCCASION" (10pt uppercase); textarea 64pt tall with placeholder text; send arrow button (38×38, `--accent`, 12pt radius) bottom-right, opacity 0.3 when empty
- **Occasion chips**: Scrollable row — "Wedding guest", "Sangeet night", "Diwali party", "Eid lunch", "Reception". In light mode each chip gets its own jewel color (already defined as `ChipColor` static props in DesignSystem.swift). Tapping fills the prompt and submits.
- **Recent searches**: Section label "RECENT SEARCHES"; horizontal scroll row of 3 items (80×106, 14pt radius), dark gradient backgrounds with tiny caption.
- **Bottom nav**: Always visible on Home/Saved/Profile. 3 tabs: ✦ Discover, ♡ Saved, ◎ Profile. Active = full opacity icon + `--accent` label. Hidden on Loading and Results screens.

### Loading Screen
- Follows app theme (light in light mode, dark in dark mode)
- Centered: "Shauk" in `--accent` Playfair 32pt
- Animated step text (switches every ~700ms): "Parsing your occasion…" → "Searching Indian fashion sites…" → "Screenshotting product pages…" → "Curating your feed…"
- 3 pulsing dots (5×5, staggered 0.2s delays)
- Query shown in italic card below dots

### Results List View (Phase 2 placeholder — Phase 3 replaces with swipe feed)
- Follows app theme (light in light mode, dark in dark mode)
- List of outfit cards: image/color placeholder, brand (10pt uppercase accent), name (Playfair 20pt), price + occasion, tags
- Back button to return to Home

### Profile Screen
- Avatar circle "S" (72pt, gradient gold→brown, Playfair 26pt)
- "Shauk Member" name, "Gender · Top size · Bottom size" detail (reads from UserDefaults)
- **Theme toggle** (Dark 🌙 / Light ☀️ pill) — updates `AppStorage("theme")`
- Sections: Appearance, Your Sizes (Top/Bottom/Edit measurements), Activity (Items saved, Searches), Account (Notifications, Privacy, Sign out — all stub rows)

### Saved Screen (Phase 4 stub)
- Header "Your wardrobe" + back button + count
- Empty state: ✦ icon + "Nothing saved yet" + instruction text

---

## Architecture Decisions

### Search Pipeline (Vercel Free Tier)
**Synchronous approach** — POST `/api/search` does everything in one request and returns cards directly. No jobId/polling needed in Phase 2.

Flow:
1. Receive `{ occasion, gender?, top_size?, bottom_size?, bust_in?, waist_in?, ... }`
2. Call Gemini 2.5 Flash with full user profile → get 1-2 personalised search query strings
3. Call Google CSE → get top 5 product page URLs
4. Call Puppeteer microservice for all 5 URLs **in parallel** (`Promise.allSettled`)
5. Filter out failed screenshots
6. Return `{ ok: true, cards: OutfitCard[] }`

Target: ~6-8s total. Risk: 10s Vercel timeout if sites are slow. Mitigation: 8s per-screenshot timeout, skip failures gracefully, target only 3-5 results.

### Image Storage
Return screenshot as `imageBase64` (PNG) embedded in the JSON response for Phase 2 simplicity. Supabase Storage migration is a Phase 3+ concern.

### Supabase Table (new)
`search_jobs` table — for caching and future analytics:
```sql
create table search_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users,
  occasion text not null,
  cards jsonb not null default '[]',
  created_at timestamptz default now()
);
alter table search_jobs enable row level security;
create policy "Users own their searches" on search_jobs
  for all using (auth.uid() = user_id);
```

---

## Files to Create / Modify

### iOS App (`shauk/`)

**Create:**
- `shauk/Views/Main/MainTabView.swift` — Tab container (Discover/Saved/Profile tabs + overlay for Loading/Results)
- `shauk/Views/Home/HomeView.swift` — Home screen per design
- `shauk/Views/Home/LoadingView.swift` — 4-step loading animation
- `shauk/Views/Home/ResultsListView.swift` — Basic results list (Phase 3 replaces this)
- `shauk/Views/Profile/ProfileView.swift` — Profile with theme toggle
- `shauk/Views/Saved/SavedView.swift` — Empty state stub
- `shauk/ViewModels/HomeViewModel.swift` — Search state + APIService calls
- `shauk/Models/OutfitCard.swift` — Codable OutfitCard + SearchResponse models

**Modify:**
- `shauk/ContentView.swift` — Replace `HomeStubView` with `MainTabView`
- `shauk/Services/APIService.swift` — Add `search(occasion:profile:)` method
- `shauk/CLAUDE.md` — Update feed theme note + add design file URL reference

### shauk-api (`shauk-api/`)

**Create:**
- `app/api/search/route.ts` — POST handler
- `lib/gemini.ts` — Gemini 2.5 Flash query generator
- `lib/googleSearch.ts` — Google CSE wrapper

**Modify:**
- `.env.example` — Add `GEMINI_API_KEY`, `GOOGLE_SEARCH_API_KEY`, `GOOGLE_SEARCH_ENGINE_ID`, `SCREENSHOT_SERVICE_URL`, `SCREENSHOT_API_KEY`
- `package.json` — Add `@google/generative-ai`, `googleapis`

### shauk-screenshot (`shauk-screenshot/`)

**Modify:**
- `src/index.ts` — Implement the POST `/screenshot` handler (replace 501 stub)
  - 390×844 viewport
  - `networkidle2`, 10s page timeout
  - Find largest `<img>` above the fold by `naturalWidth × naturalHeight`
  - Crop screenshot to element bounding box
  - Return `{ ok: true, imageBase64: string }` (PNG, base64)

---

## Detailed Implementation

### `OutfitCard.swift`
```swift
struct OutfitCard: Codable, Identifiable {
    let id: String
    let brand: String
    let name: String
    let price: String?
    let occasion: String?
    let tags: [String]
    let imageBase64: String   // base64 PNG
    let sourceURL: String

    var image: UIImage? {
        guard let data = Data(base64Encoded: imageBase64) else { return nil }
        return UIImage(data: data)
    }

    enum CodingKeys: String, CodingKey {
        case id, brand, name, price, occasion, tags
        case imageBase64 = "image_base64"
        case sourceURL   = "sourceURL"
    }
}

struct SearchResponse: Codable {
    let ok: Bool
    let cards: [OutfitCard]?
    let error: String?
}
```

### `HomeViewModel.swift`
```swift
@Observable
@MainActor
final class HomeViewModel {
    var prompt: String = ""
    var phase: Phase = .idle

    enum Phase: Equatable {
        case idle
        case loading
        case results([OutfitCard])
        case error(String)
        static func == (lhs: Phase, rhs: Phase) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading): return true
            default: return false
            }
        }
    }

    var canSearch: Bool { !prompt.trimmingCharacters(in: .whitespaces).isEmpty }

    // Loaded on init — fetches the user's Supabase profile so sizing/measurements
    // are included in the Gemini search query for personalised results
    var userProfile: UserProfile? = nil

    func loadProfile() async {
        guard let idString = UserDefaults.standard.string(forKey: "supabaseUserId"),
              let id = UUID(uuidString: idString) else { return }
        userProfile = try? await SupabaseService.shared.fetchProfile(id: id)
    }

    func search() async {
        guard canSearch else { return }
        phase = .loading
        do {
            let cards = try await APIService.shared.search(occasion: prompt, profile: userProfile)
            phase = .results(cards)
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func reset() {
        phase = .idle
        // keep prompt so user can refine
    }
}
```

### `APIService.swift` addition

`HomeViewModel` reads the full `UserProfile` from Supabase and passes it here so the backend Gemini prompt is personalised with gender, sizes, and measurements.

```swift
struct SearchRequest: Encodable {
    let occasion: String
    let gender: String?
    let top_size: String?
    let bottom_size: String?
    // measurements (inches — only sent if non-nil)
    let bust_in: Double?
    let waist_in: Double?
    let hips_in: Double?
    let chest_in: Double?
    let shoulders_in: Double?
    let sleeve_length_in: Double?
    let inseam_in: Double?
}

func search(occasion: String, profile: UserProfile?) async throws -> [OutfitCard] {
    var req = URLRequest(url: baseURL.appendingPathComponent("api/search"))
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.timeoutInterval = 30
    let body = SearchRequest(
        occasion: occasion,
        gender: profile?.gender?.rawValue,
        top_size: profile?.topSize?.rawValue,
        bottom_size: profile?.bottomSize?.rawValue,
        bust_in: profile?.bustIn,
        waist_in: profile?.waistIn,
        hips_in: profile?.hipsIn,
        chest_in: profile?.chestIn,
        shoulders_in: profile?.shouldersIn,
        sleeve_length_in: profile?.sleeveLengthIn,
        inseam_in: profile?.inseamIn
    )
    req.httpBody = try JSONEncoder().encode(body)
    let (data, _) = try await URLSession.shared.data(for: req)
    let response = try JSONDecoder().decode(SearchResponse.self, from: data)
    guard response.ok, let cards = response.cards else {
        throw APIError.searchFailed(response.error ?? "Unknown error")
    }
    return cards
}
```

### `lib/gemini.ts`
```typescript
import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

export interface UserContext {
  gender?: string;           // "female" | "male"
  topSize?: string;          // "XS" | "S" | "M" | "L" | "XL" | "XXL"
  bottomSize?: string;
  // measurements in inches (optional — only if user entered them)
  bustIn?: number; waistIn?: number; hipsIn?: number;
  chestIn?: number; shouldersIn?: number; sleeveLengthIn?: number;
  inseamIn?: number;
}

export async function generateSearchQuery(occasion: string, user: UserContext): Promise<string[]> {
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

  const userLines: string[] = [];
  if (user.gender)     userLines.push(`Gender: ${user.gender}`);
  if (user.topSize)    userLines.push(`Top size: ${user.topSize}`);
  if (user.bottomSize) userLines.push(`Bottom size: ${user.bottomSize}`);

  const mParts: string[] = [];
  if (user.bustIn)         mParts.push(`bust ${user.bustIn}"`);
  if (user.chestIn)        mParts.push(`chest ${user.chestIn}"`);
  if (user.waistIn)        mParts.push(`waist ${user.waistIn}"`);
  if (user.hipsIn)         mParts.push(`hips ${user.hipsIn}"`);
  if (user.shouldersIn)    mParts.push(`shoulders ${user.shouldersIn}"`);
  if (user.sleeveLengthIn) mParts.push(`sleeve ${user.sleeveLengthIn}"`);
  if (mParts.length) userLines.push(`Measurements: ${mParts.join(", ")}`);

  const userBlock = userLines.length
    ? `\n\nUser profile:\n${userLines.join("\n")}`
    : "";

  const systemPrompt = `You are a search query generator for an Indian occasion wear discovery app called Shauk.
Given an occasion description and the user's profile (gender, sizes, measurements), generate 1-2 targeted Google search queries that will find relevant Indian ethnic wear product pages.
The queries must be tailored to the user's gender and size so results surface clothing that fits them.
Target sites: sabyasachi.com, anitadongre.com, manishmalhotra.in, rawmango.in, nykaa.com, ajio.com, aza-fashions.com, manyavar.com, fabindia.com

Occasion: "${occasion}"${userBlock}

Rules:
- If gender is female, focus on: lehengas, anarkalis, sarees, sharara sets, salwar suits
- If gender is male, focus on: kurta sets, sherwanis, bandhgalas, Indo-western suits
- Include the size (e.g. "size M lehenga") only if it helps narrow results
- Keep queries concise (4-8 words)

Return ONLY a JSON array of query strings. Example: ["anita dongre anarkali wedding guest size S", "raw mango chanderi lehenga reception"]`;

  const result = await model.generateContent(systemPrompt);
  const text = result.response.text().trim();
  const match = text.match(/\[[\s\S]*\]/);
  if (!match) throw new Error("Gemini returned no valid queries");
  return JSON.parse(match[0]) as string[];
}
```

### `lib/googleSearch.ts`
```typescript
import { google } from "googleapis";

const customsearch = google.customsearch("v1");

export async function searchProducts(query: string, count = 5): Promise<string[]> {
  const res = await customsearch.cse.list({
    auth: process.env.GOOGLE_SEARCH_API_KEY,
    cx: process.env.GOOGLE_SEARCH_ENGINE_ID,
    q: query,
    num: count,
  });
  return (res.data.items ?? [])
    .map(item => item.link)
    .filter((link): link is string => !!link);
}
```

### `app/api/search/route.ts`
```typescript
import { NextRequest, NextResponse } from "next/server";
import { generateSearchQuery } from "@/lib/gemini";
import { searchProducts } from "@/lib/googleSearch";

export const maxDuration = 60; // Vercel Pro; free tier ignores (10s hard limit)

export async function POST(req: NextRequest) {
  const body = await req.json();
  const { occasion, gender, top_size, bottom_size } = body;
  if (!occasion) return NextResponse.json({ ok: false, error: "occasion required" }, { status: 400 });

  // 1. Gemini → personalised queries (includes gender, sizes, measurements)
  const queries = await generateSearchQuery(occasion, {
    gender,
    topSize: top_size,
    bottomSize: bottom_size,
    bustIn: body.bust_in,
    waistIn: body.waist_in,
    hipsIn: body.hips_in,
    chestIn: body.chest_in,
    shouldersIn: body.shoulders_in,
    sleeveLengthIn: body.sleeve_length_in,
    inseamIn: body.inseam_in,
  });

  // 2. Google CSE → URLs
  const urls = await searchProducts(queries[0], 5);

  // 3. Screenshots in parallel (skip failures gracefully)
  const screenshotResults = await Promise.allSettled(
    urls.map(url => fetchScreenshot(url))
  );

  const cards = screenshotResults
    .map((result, i) =>
      result.status === "fulfilled" ? { ...result.value, sourceURL: urls[i] } : null
    )
    .filter(Boolean);

  return NextResponse.json({ ok: true, cards });
}

async function fetchScreenshot(url: string) {
  const res = await fetch(`${process.env.SCREENSHOT_SERVICE_URL}/screenshot`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": process.env.SCREENSHOT_API_KEY!,
    },
    body: JSON.stringify({ url }),
    signal: AbortSignal.timeout(8000),
  });
  const data = await res.json();
  if (!data.ok) throw new Error(data.error);
  return {
    id: crypto.randomUUID(),
    brand: extractBrand(url),
    name: "Outfit",
    price: null,
    occasion: null,
    tags: [],
    image_base64: data.imageBase64,
  };
}

function extractBrand(url: string): string {
  const host = new URL(url).hostname.replace("www.", "");
  const brandMap: Record<string, string> = {
    "sabyasachi.com": "Sabyasachi",
    "anitadongre.com": "Anita Dongre",
    "rawmango.in": "Raw Mango",
    "nykaa.com": "Nykaa Fashion",
    "ajio.com": "AJIO",
    "manyavar.com": "Manyavar",
    "manishmalhotra.in": "Manish Malhotra",
    "fabindia.com": "Fabindia",
    "aza-fashions.com": "Aza Fashions",
  };
  return brandMap[host] ?? host.split(".")[0];
}
```

### `src/index.ts` (screenshot service — replace 501 stub)
```typescript
app.post('/screenshot', async (req, res) => {
  const { url } = req.body;
  if (!url) return res.json({ ok: false, error: 'url required', code: 'UNKNOWN' });

  let browser;
  try {
    browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 390, height: 844 });
    await page.goto(url, { waitUntil: 'networkidle2', timeout: 10000 });

    // Find largest <img> above the fold by natural pixel area
    const rect = await page.evaluate(() => {
      const imgs = Array.from(document.querySelectorAll('img'));
      const above = imgs.filter(img => img.getBoundingClientRect().top < window.innerHeight);
      if (!above.length) return null;
      const best = above.reduce((a, b) =>
        b.naturalWidth * b.naturalHeight > a.naturalWidth * a.naturalHeight ? b : a
      );
      const r = best.getBoundingClientRect();
      return { x: r.left, y: r.top, width: r.width, height: r.height };
    });

    if (!rect || rect.width < 50 || rect.height < 50)
      return res.json({ ok: false, error: 'No product image found', code: 'NO_IMAGE' });

    const screenshot = await page.screenshot({
      clip: rect,
      encoding: 'base64',
      type: 'png',
    });
    res.json({ ok: true, imageBase64: screenshot });
  } catch (err: any) {
    const code = err.message?.includes('timeout') ? 'TIMEOUT' : 'UNKNOWN';
    res.json({ ok: false, error: err.message, code });
  } finally {
    await browser?.close();
  }
});
```

### `MainTabView.swift` navigation model
```swift
// Three tabs; Loading and Results overlay the full screen (no tab bar shown)
enum MainTab { case discover, saved, profile }

struct MainTabView: View {
    @State private var tab: MainTab = .discover
    @State private var vm = HomeViewModel()

    var body: some View {
        ZStack {
            switch vm.phase {
            case .loading:
                LoadingView(query: vm.prompt)
                    .transition(.opacity)
            case .results(let cards):
                ResultsListView(cards: cards, onBack: { vm.reset() })
                    .transition(.opacity)
            default:
                VStack(spacing: 0) {
                    tabContent
                    BottomNavBar(tab: $tab)
                }
                .transition(.opacity)
            }
        }
        .animation(.shaukFade, value: isOverlay)
        .task { await vm.loadProfile() }
    }

    private var isOverlay: Bool {
        if case .idle = vm.phase { return false }
        if case .error = vm.phase { return false }
        return true
    }

    @ViewBuilder var tabContent: some View {
        switch tab {
        case .discover: HomeView(vm: vm)
        case .saved:    SavedView()
        case .profile:  ProfileView()
        }
    }
}
```

---

## Credential Setup (needed before running)

Add to `shauk-api/.env.local`:
```
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
GEMINI_API_KEY=...              # Google AI Studio → https://aistudio.google.com
GOOGLE_SEARCH_API_KEY=...      # Google Cloud Console → Custom Search JSON API
GOOGLE_SEARCH_ENGINE_ID=...    # https://programmablesearchengine.google.com
SCREENSHOT_SERVICE_URL=...     # https://your-service.onrender.com
SCREENSHOT_API_KEY=...         # Random secret matching .env in shauk-screenshot
```

Add to `shauk-screenshot/.env`:
```
API_KEY=...   # same as SCREENSHOT_API_KEY above
PORT=3001
```

For Google CSE: configure the search engine to target Indian fashion sites (sabyasachi.com, anitadongre.com, rawmango.in, nykaa.com, ajio.com, manyavar.com, aza-fashions.com, manishmalhotra.in, fabindia.com).

---

## Verification

1. **Screenshot service**: `curl -X POST http://localhost:3001/screenshot -H "x-api-key: test" -H "Content-Type: application/json" -d '{"url":"https://rawmango.in"}' | jq .ok`
2. **API search**: `curl -X POST http://localhost:3000/api/search -H "Content-Type: application/json" -d '{"occasion":"cousin wedding Mumbai","gender":"female","top_size":"M"}' | jq '.cards[0].brand'`
3. **iOS simulator**: Tap through onboarding → home screen → type occasion → tap send → verify loading animation (4 steps) → verify results list appears
4. **Theme**: Profile tab → toggle Dark ↔ Light → verify ALL screens (including Loading and Results) reflect the change
5. **Bottom nav**: Verify tab bar shows on Discover/Saved/Profile, hidden during Loading and Results
6. **Personalisation**: Complete onboarding with gender=female, size=M, waist=28" → search → verify API receives those values and Gemini query reflects them
