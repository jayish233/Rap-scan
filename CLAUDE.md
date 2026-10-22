# CLAUDE.md — RAPscanz Flutter

Execution plan and working rules for Claude Code. Read this fully before writing code.

## Source of truth (in priority order)

1. **PRD.md** — product requirements; the final word on behavior, copy, and gating.
2. **architecture.md** — system design, schema, edge-function pipeline, module layout.
3. **design.md** — visual language, screen specs, and the verbatim copy deck (§10).

If these conflict, follow PRD.md and flag the conflict to the user. Do not invent features beyond PRD §4 (in scope). Respect §4 "explicitly out of scope" (no on-device analysis engine, no barcode-prefix guessing, no social features, no dark mode, no live checkout, no scan edit/delete UI, no photo archive).

## Project

- Cross-platform **Flutter** app (iOS + Android, one codebase) reproducing the RAPscanz web product: paste ingredients / photograph a label / scan a barcode → 0–100 health score, rating, calories, advantages, disadvantages, chemical cautions, personalized advice.
- **Backend: Supabase** (Auth, Postgres + RLS, edge function `analyze-scan`, DB functions `consume_quota` / `get_leaderboard`). The backend does not exist yet — Phase 0 builds it from architecture.md §3.
- **State management: Riverpod** (code-gen free). Routing: go_router. Layout: feature-first per architecture.md §2.2.

## Commands

```bash
flutter pub get
flutter analyze                 # must stay clean
flutter test                    # unit + widget tests
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
supabase start                  # local backend (Phase 0)
supabase db push                # apply migrations
supabase functions deploy analyze-scan
supabase secrets set GEMINI_API_KEY=...
```

## Hard rules (never violate)

1. **The AI key and service-role key never ship in the app.** The phone never calls the model or food registries directly — only the `analyze-scan` edge function.
2. **Quota is enforced on the server only.** The client displays `remaining`/`scanLimit`/`planLabel`. Never reset or compute quotas on the phone. Monthly reset is an open server decision (PRD §16) — do not implement a client-side cycle.
3. **Never invent product identity from a barcode.** Registry miss → the verbatim registry-miss error → offer photo/paste. GS1 prefix is only a country hint (India = 890).
4. **Credits:** validation failures (bad check digit, empty text, oversize image, in-store `2*` code) must not reach the server — validate on device first. Successful analysis consumes 1 credit before the model call, including cache hits.
5. **Dietary rules:** egg is non-veg (Indian convention). Gelatin, carmine/E120, shellac/E904, L-cysteine (unless microbial), animal rennet → non-veg. Mono/diglycerides → veg unless clearly animal. D3 lanolin veg / lichen vegan.
6. **Gating:** Pro Max features visible when `plan == pro_max` OR `isUnlimited` OR `plan == unlimited`. Expired paid plan = Free. Hide locked sections even if a stale payload contains them; locked teasers must never reveal organ names/severities/reasons or the dietary reason.
7. **User-facing copy is verbatim** from design.md §10 — do not paraphrase error messages, empty states, or disclaimers.
8. **Privacy:** health profile fields never appear in leaderboard responses. Photos are never persisted server-side. No third-party ad SDKs; crash reporting must not include ingredient text, photos, or health fields.
9. **No live payments.** Plan cards and upgrade messaging display only; buttons say payments are coming (PRD §9).
10. **Persistent disclaimer** on Home and in the result footer: informational, not medical advice.

---

## Phased build plan

Complete phases in order. Do not start a phase until the previous phase's gate passes. After each phase: `flutter analyze` clean, relevant tests green.

### Phase 0 — Supabase backend

Build from architecture.md §3 (the web backend repo is absent; this recreates it).

**Files to create:**
- `supabase/config.toml`, migrations under `supabase/migrations/`:
  - `0001_profiles.sql` — profiles table, username unique index on `lower(username)`, RLS
  - `0002_scans.sql` — scans (+ list projection columns), consumption, scan_feedback (unique per user+scan), RLS
  - `0003_cache_roles_payments.sql` — barcode_cache (no client read), user_roles, payments (select own), RLS
  - `0004_functions.sql` — `get_leaderboard()` (min 3 scans, avg desc, count desc, cap 50), `consume_quota(uuid)` (effective-plan resolution incl. expiry → free; roles admin/founder/collaborator → unlimited sentinel 999,999 recorded as pro_max; increment lifetime scan_count; return remaining/scanLimit/plan/planLabel/isUnlimited)
  - `0005_protect_plan_columns.sql` — block client writes to plan/plan_expires_at/scan_count/is_subscribed/subscription_expires_at
- `supabase/functions/analyze-scan/index.ts` — the 13-step pipeline (architecture.md §3.3 flowchart): validate → quota → health profile → photo OCR (digit runs 8–14, ignore dates/prices/batch/phones/weights, prefer lengths 13→12→14→8, 12→13 promotion) → in-store short-circuit → barcode_cache → OFF v2 → UPCitemdb (12-digit retry with leading 0) → model (JSON mode, tier-specific instructions per effective plan) → clamp score 0–100 / calories 0–5000 → registry identity overwrite → deterministic organ rule engine → insert scans + upsert cache → return result + scanId/remaining/scanLimit/plan/planLabel
- `supabase/functions/analyze-scan/organImpact.ts` — deterministic rule engine (architecture.md §3.4), versioned `organRules.v1`, with unit fixtures
- `supabase/functions/analyze-scan/prompt.ts` — model instructions: scoring intent, per-serving calories, specific categories, dietary rules, risk-profile grounding (WHO/FDA/EFSA/ICMR-NIN/AHA/NIH), tier-gated fields
- Tests for the edge function (deno test): quota ordering, registry fallback, identity overwrite, organ-rule determinism, tier-gated field omission, leaderboard SQL

**Gate:** against local Supabase, curl `analyze-scan` with a known Indian 890… EAN-13 present in Open Food Facts → valid PRD §11.1 JSON with registry identity (not guessed); repeat call returns identical score/summary from cache and still consumes a credit; an invalid-check-digit barcode is rejected without consuming credit.

### Phase 1 — App shell, theme, auth

**Files:**
- `pubspec.yaml` — add: `supabase_flutter`, `flutter_riverpod`, `go_router`, `flutter_secure_storage`, `shared_preferences`, `freezed`, `json_serializable` (+ dev: `build_runner`, `freezed`, `json_serializable`); register bundled OFL fonts (Bricolage Grotesque, Plus Jakarta Sans)
- `lib/app/theme.dart` — tokens per design.md §2
- `lib/app/router.dart` — go_router: `/`, `/home`, `/auth`, `/leaderboard`, `/trust`, `/guides/healthy-snacks`, authenticated shell with bottom nav (`/scan`, `/history`, `/weekly`, `/leaderboard`, `/profile`) + `/history/:id`; redirect: signed-out hitting gated tabs → `/auth`; existing session → `/scan`
- `lib/app/session.dart` — auth state from `Supabase.instance.client.auth.onAuthStateChange`
- `lib/data/supabase_client.dart` — init from `--dart-define`
- `lib/features/auth/` — email+password sign-in/sign-up toggle (min password 6), provider errors as toast/inline
- `lib/features/home/` — headline, supporting copy, Start scanning CTA (→ auth/scan), 3 how-it-works hard-offset cards, pricing cards (design.md §5), disclaimer footer, links to Leaderboard/Trust/guide
- `lib/features/content/` — Trust & privacy (PRD §7.10 statements), healthy-snacks guide page
- Splash with brand mark; strings class mirroring design.md §10

**Gate (PRD §14.1):** new user signs up → lands on Scan → sees "Free · 30 of 30 scans left" (quota chip may read a stub profile row from Phase 0); sign-out returns to Home; leaderboard/trust/guide reachable signed out (§14.14 partial).

### Phase 2 — Scan core (text + manual barcode) and History

**Files:**
- `lib/domain/` — `barcode.dart` (strip non-digits, lengths 8/12/13/14, GS1 check digit, in-store `^2\d{7,13}$` detector), `scan_result.dart`, `rating.dart`, `plan.dart` (effective plan, isProMax), score-band labels (design.md §7.1)
- `lib/data/dto/` — freezed DTOs for §11.1 result + envelope + error envelope (architecture.md §4)
- `lib/data/scan_api.dart` — edge-function call, typed failures → verbatim copy
- `lib/features/scan/scan_screen.dart` — Text and Barcode modes, plan chip, primary button "Scan & analyze", laser animation, disabled state, all error toasts (quota/rate-limit/AI/registry-miss/invalid/no-network)
- `lib/features/scan/result/` — blocks 1–5, 7, 9 (verdict header, HealthScoreRing, summary, For you, calories, I ate this placeholder, advantages/disadvantages, cautions) + result footer disclaimer; clamp score/calories on display
- `lib/features/history/` — list (newest first, ≤ 50, row per design.md §4.6, empty state, offline cache + refresh) and detail `/history/:id` (saved analysis, no re-run, "Scan not found")

**Gates (PRD §14.2–5):** pasted ingredient list returns full un-gated result and appears in history; a known 890… EAN-13 returns registry name/brand; rescan returns identical score/summary; bad check digit never reaches the model and does not decrement quota; unknown-but-valid barcode shows the registry-miss error.

### Phase 3 — Camera, live scanner, local inventory

**Files:**
- `pubspec.yaml` — add `mobile_scanner`, `image_picker`, `flutter_image_compress`
- `lib/features/scan/` — Photo mode (capture rear / pick library, > 5 MB device reject with verbatim message, preview + remove, compress before upload); live barcode scanner overlay (EAN-8/13, UPC-A, ITF-14) filling the field and submitting; camera-permission denial explainer with paste/manual fallback
- `lib/data/local_barcodes_store.dart` — `rapscanz.localBarcodes.v1` map `{ barcode: { name, price?, weight?, savedAt } }`
- `lib/features/scan/local/` — saved card ("Saved on this device."), add dialog (name required, price/weight optional), delete; photo-OCR → local flow + verbatim toast

**Gates (PRD §14.6–7):** `2*`-prefixed code opens local inventory, spends no credit, recognized after app restart; photo under 5 MB resolves to a barcode result or image analysis; over-5 MB rejected on device.

### Phase 4 — Plan gating & Pro Max sections

**Files:**
- `lib/features/scan/result/` — block 6 dietary badge + reason (Pro Max) / locked card; block 8 safe consumption guide (Pro+); block 10 over-consumption risk profile (Pro Max); block 11 BodyDamageMap — `CustomPainter` or SVG with tappable regions, two front silhouettes (harms amber/orange/red, benefits greens), 13 organ keys, subject's-left-on-viewer's-right anatomy, tap → reason + trigger, empty-side messages, text-list equivalent for screen readers; blurred locked teaser below Pro Max revealing nothing
- `lib/features/plans/` — plans sheet: 4 cards + current plan, "payments coming" buttons (no checkout)
- Server-side: confirm gated fields omitted per caller plan (Phase 0 tests cover)

**Gates (PRD §14.11–12):** Free sees locked teasers for dietary + body map and no formulas/consumption guide/risk profile; Pro Max (or unlimited role) sees dietary badge with reason, both silhouettes, risk profile for non-healthy-band products; expired paid plan behaves as Free.

### Phase 5 — Weekly, Leaderboard, Profile, Feedback

**Files:**
- `lib/data/weekly_repository.dart`, `lib/features/weekly/` — I-ate-this wiring (enabled when `scanId` exists, "Added to this week"), 7 local-calendar-day window from local midnight, total + average/7, 7 weekday bars relative to busiest day, entry list with delete (removes log only), re-logging allowed, empty state
- `lib/data/leaderboard_repository.dart`, `lib/features/leaderboard/` — public, 🥇🥈🥉 / `#n`, `@username`, rounded average, scan count, empty state, no health fields
- `lib/features/profile/` — username (3–20, letters/numbers/underscore, case-insensitive unique, verbatim errors), health info form (gender/age/weight/height/conditions/allergies with PRD limits), live BMI one decimal, privacy copy, "Profile saved!" toast, sign out
- `lib/data/feedback_repository.dart` + result block 12 — stars, Yes/Maybe/No, comment ≤ 1000, upsert per (user, scan), thank-you state, saved values on reopen

**Gates (PRD §14.8–10, 13):** with weight+height+allergy saved, a later scan can show "For you"; those fields absent from leaderboard; I-ate-this increments weekly total, delete removes only the log, same scan re-loggable; < 3 scans or no username ⇒ absent from leaderboard; feedback persists across reopen.

### Phase 6 — Polish, accessibility, hardening

- Toasts/inline cards everywhere per design.md §10; scanner animation non-blocking; empty/loading/error states for every screen (design.md §9)
- Offline: history + profile from cache, refresh online; no-network message on Scan; local inventory works offline
- Accessibility pass (design.md §8): semantics on rating/score/cautions (never color alone), organ text list, dynamic type without ring clipping, ≥ 44 pt targets — verify §14.15 with VoiceOver/TalkBack
- Edge cases (PRD §15): expired plan → Free on next scan; credit kept on model failure with reduced count shown; cache hit writes personal scans row; OCR ignores expiry/MRP/net-weight; clamps on dirty rows; weekly local-day grouping; silent RLS failure on cross-user delete
- Test suite: domain unit tests (validators, organ rules port fixtures, plan helper), edge-function tests, widget tests for scan flow + gating; `flutter analyze` clean

**Final gate:** all 15 acceptance criteria in PRD §14 verified end-to-end.

---

## Open decisions — do NOT implement client-side (PRD §16)

1. **Billing path** (App Store / Play billing vs web Razorpay): display plans only.
2. **Monthly quota reset**: server-side decision; client only displays server numbers.
3. **Photo-OCR in-store credit cost**: avoid by device-side `2*` detection before upload when the scanner reads the code directly.

## Environment

- `SUPABASE_URL`, `SUPABASE_ANON_KEY` — via `--dart-define` (placeholders until provided).
- `GEMINI_API_KEY` — Supabase edge-function secret only, set in Phase 0. The edge function calls the Gemini API (Gemini 2.5 Flash, JSON mode) directly; it is the only place this key exists.
