# RAPscanz — Flutter design spec (iOS + Android)

Hand this file to Cursor. It describes 7 screens per platform, the design tokens, the widgets to use, and the behaviour taken from the existing web app (`Adibas2009/rapscanz-food-tech`, TanStack Start + Supabase). The `screens/` folder holds the HTML mockups as visual reference (open in a browser; fonts load from Google Fonts). All product names, scores, usernames and kcal numbers in the mockups are placeholder data.

## 1. App summary
RAPscanz scans packaged food (ingredient text, label photo, or barcode) and returns a health score, advantages, disadvantages, chemical cautions, calories and (on higher plans) organ impact. Users can log what they ate (weekly calories), see history, a leaderboard, and a profile used to personalise advice.

Plans (scans): Free 30 total · Pro ₹200/mo, 60/mo · Pro+ ₹500/mo, 120/mo · Pro Max ₹1200/mo, 240/mo · Unlimited (internal). Payments are not live yet ("coming soon").
- Pro+: % of each chemical, "Safe consumption guide", what each chemical can cause.
- Pro Max: dietary classification (Veg / Non-veg / Vegan), over-consumption risk profile, body-impact (organ) map.

## 2. Design tokens
Fonts (package `google_fonts`): **Bricolage Grotesque** (headings, numbers, weight 700–800, letter-spacing about -3.5%) and **Plus Jakarta Sans** (body, 400–700). Mono for formulas/percentages: system monospace.

| Token | Hex |
|---|---|
| primary | #1B7746 |
| accent (leaf green) | #72D66F (text on it #14301F) |
| background | #FAFDFA |
| surface / card | #FFFFFF |
| onSurface | #1D242B |
| muted text | #5C6670 |
| border / outline variant | #E3EBE5 (iOS) · #CBD5CD (Android cards) |
| Android input outline | #6F7A72 |
| tonal container (Android selected, nav indicator) | #CDEFCB, text #0A2E17 |
| surface container (Android nav bar, tonal cards) | #EEF4EF |
| danger | #D13A2E |
| warning (amber) | #F0A63A |
| success | #4CC27C |
| dark panel (viewfinder, body map card) | #0F1A14 |

Rating colours: good = success, okay = accent, caution = warning, avoid = danger. Rating banner text is dark (#1D242B) on warning/accent, dark green on success.

Health score ring: near-black disc (#0B1220), track #334155, progress colour by score: ≥70 #34D399 (number #6EE7B7), 40–69 #FCD34D (#FDE68A), <40 #FB7185 (#FDA4AF). Sizes: large 92 (stroke 9), small 56 (stroke 6). Score labels: ≥85 "Excellent for you", ≥70 "Healthy choice", ≥40 "Okay in moderation", ≥20 "Eat rarely", else "Better avoid". Also shown as score/10.

Radii: iOS cards 16–24, buttons 14–16; Android cards 16–20, buttons fully rounded (26), inputs 4. Touch targets ≥44 (iOS) / 48 (Android).

Flutter: `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1B7746)).copyWith(primary: ..., secondary: Color(0xFF72D66F), surface: Colors.white, error: Color(0xFFD13A2E)))`, `scaffoldBackgroundColor: Color(0xFFFAFDFA)`. Use `Platform.isIOS` (or `TargetPlatform`) to pick Cupertino vs Material variants below.

## 3. Navigation
Bottom bar with 5 destinations: **Scan, History, Weekly, Ranks, Profile**. Result is pushed from Scan or History (back arrow). Unauthenticated users see Sign in first.
- iOS: `CupertinoTabBar`/`CupertinoTabScaffold`, 10px labels, active = primary.
- Android: `NavigationBar` with pill indicator (#CDEFCB), 12px labels.

## 4. Screens

### 4.1 Sign in / Create account
Logo (rounded green gradient square with scan corners + leaf) + wordmark "RAP**scanz**" (scanz in primary). Title "Welcome back", subtitle "Sign in to keep scanning." Mode switch Sign in / Create account (iOS `CupertinoSlidingSegmentedControl`, Android `SegmentedButton`). Fields: email, password (min 6 chars; Android shows eye toggle). Primary button. Create mode subtitle: "30 free scans, no card needed." Footer: "For information only — not medical advice." Backend: Supabase `signInWithPassword` / `signUp`; on success go to Scan. Errors as snackbar/toast. iOS form card has a 5px offset leaf-green shadow (brand detail).

### 4.2 Scan
Title "Scan" + plan chip ("Free · 24 of 30 left", or "<Plan> · Unlimited scans"). Mode selector: **Text | Photo | Barcode**.
- Text: multiline field "Paste the ingredient list from the back of the packet…".
- Photo: dashed drop area "Tap to take a photo or upload the food label"; preview with remove (X); max 5 MB (`image_picker`).
- Barcode (shown in mockups): live camera viewfinder (`mobile_scanner`) with green corner brackets, laser line, flashlight toggle, hint "Align the barcode inside the frame"; plus numeric field (digits only). Helper: "EAN-8, UPC-A, EAN-13 or ITF-14. In-store labels (prefix 20–29) are saved on your device and use no scan credit." The live camera is a new idea; the web app only types the number.
Primary button "Scan & analyze" (disabled while loading; loading state = small scanner animation + "Analyzing your scan…"). If out of scans: warning card "You've used all your scans" with upgrade info and disable the button (except local barcodes).
Local barcode rule: digits only, 8–14 long, starts with `2` → not sent to the server; look up the on-device store (key `rapscanz.localBarcodes.v1` in the web app, use `shared_preferences`). Unknown → dialog asking name, optional price, optional weight; known → show "Local inventory item" card with Remove.

### 4.3 Result (also History detail)
1. Header card, background by rating, label (GOOD CHOICE / OKAY-ISH / CAUTION / BETTER AVOID), product name, brand · "by <parentCompany>" · category, optional "Identified via AI Registry Lookup" chip, health score ring + label.
2. Summary paragraph; "For you:" tip with heart icon (from profile); kcal chip "~N kcal per serving"; button **I ate this** (becomes "Added to this week" outlined/disabled after logging).
3. Dietary classification card (**Pro Max**; locked teaser with Upgrade for others): VEG (green square), VEGAN, NON-VEG (red), reason text.
4. Advantages (+ in green) and Disadvantages (− in red) lists; "None notable." when empty.
5. Safe consumption guide (**Pro+**): "Safe / day", "Upper limit", source.
6. Chemical & ingredient cautions list: ingredient name, optional percentage chip (mono, amber tint), concern text, optional chemical formula (mono, green) and scientific name (italic), severity chip low (grey) / medium (amber) / high (red). Empty: "No flagged chemicals."
7. Over-consumption risks (**Pro Max**): groups Illnesses, Addiction patterns, Chronic damage, Temporary effects, Organ-specific damage.
8. Body impact map (**Pro Max**): dark card with organ chips + button to open a full-screen body map (damage and benefit variants; SVG silhouette, see `src/components/BodyDamageMap.tsx` and `src/lib/organImpact.ts` in the repo).
9. Rating: 5 stars, optional note, "Send feedback".
Mockups show this as one long scroll with the tab bar at the end.

### 4.4 History
List of past scans (newest first): rating dot (iOS) or rating chip (Android), product name, date · type (barcode/ingredients), 2-line summary, small health ring. Tap → Result. Empty state: icon, "No scans yet.", button "Run your first scan".

### 4.5 Weekly
Title "This week". Card: "7-DAY TOTAL" kcal, average per day, 7 bars for the last 7 days (day labels, value above each bar, today highlighted). "Entries" list: product name, date/time, kcal, delete button (confirm via snackbar "Removed"). Empty: "Nothing logged yet this week." + "Scan something".

### 4.6 Leaderboard
Top users by average health score (minimum 3 scans): rank badge (gold #F2C94C, silver #C9D1D6, bronze #E0A66B for 1–3, plain number after), `@username`, scan count, average score in primary. A highlighted "You" row is pinned at the bottom (new in this design). Empty state: "No qualifying users yet…" + sign-in button.

### 4.7 Profile
Username (3–20 chars, letters/numbers/underscore, shown on leaderboard; "That username is taken." on conflict). Plan card: plan name, "N of M scans left", progress bar, Upgrade button, price line, "Payments coming soon." Health info (optional, private): gender (Prefer not to say / Female / Male / Non-binary / Other), age (1–129), weight kg (0–500), height cm (0–300), computed BMI, conditions/illnesses (max 500), allergies (max 500). **Save profile** button, **Sign out** (danger text).

## 5. Backend (reuse the existing Supabase project)
The Flutter app can call the same Supabase backend (`supabase_flutter`). Server functions in the web repo (`src/lib/*.functions.ts`): `analyzeScan` (scan types `ingredients` with text or imageDataUrl, and `barcode`), `listScans`, `getScan`, `logConsumption`, `getWeeklyConsumption`, `getProfile`, `getLeaderboard`, feedback submit. Tables seen in the repo: `profiles` (username, gender, age, weight_kg, height_cm, illnesses, allergies, plan, plan_expires_at), `consumption`. Check `supabase/migrations/` and `src/integrations/supabase/types.ts` for the exact schema. Those server functions are TanStack Start server functions, not plain REST endpoints, so either expose them as Supabase Edge Functions / HTTP endpoints for mobile or port the logic. Do not copy secrets from `.env` into the app.

## 6. Suggested Flutter structure
`lib/theme/` (tokens, text styles), `lib/widgets/` (HealthRing, RatingBanner, CautionTile, PlanChip, StarRating), `lib/features/{auth,scan,result,history,weekly,leaderboard,profile}/`, platform-adaptive widgets (`AppSegmented`, `AppTabBar`, `AppTextField`, `AppButton`) that return Cupertino or Material versions. Suggested packages: `google_fonts`, `supabase_flutter`, `mobile_scanner`, `image_picker`, `shared_preferences`, `go_router`, `flutter_riverpod`, `flutter_svg`. Use `CustomPainter` for the health ring.

## 7. Not yet designed
Photo and Text scan tabs, local-barcode dialog, full-screen body map, empty/loading/error states, dark theme (web has a dark palette: bg oklch ≈ #14171F-ish, primary lime #A5E635-ish — derive when needed).
