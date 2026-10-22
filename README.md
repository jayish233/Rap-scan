# RAPscanz

**Know what's actually in your food.** A cross-platform Flutter app (iOS + Android) that turns a packaged-food label into a plain-English verdict: paste the ingredient list, photograph the label, or scan a barcode to get a 0–100 health score, rating, calories per serving, advantages, disadvantages, chemical cautions, and advice tailored to your health profile.

Built for Indian packaged foods and international brands. Dietary classification follows Indian convention (egg is non-vegetarian).

> RAPscanz is informational. It is not medical advice.

## Documentation

| Doc | Contents |
| --- | --- |
| [PRD.md](PRD.md) | Product requirements — the source of truth for behavior, copy, and plan gating |
| [design.md](design.md) | UX & visual spec: tokens, screens, components, accessibility, verbatim copy deck |
| [architecture.md](architecture.md) | System design: Flutter client (Riverpod, feature-first) + Supabase backend, schema, RLS, edge-function pipeline |
| [CLAUDE.md](CLAUDE.md) | Phased execution plan with acceptance gates (for Claude Code or any implementer) |

## Stack

- **Frontend:** Flutter (Dart ^3.13.5), Riverpod, go_router, freezed — one codebase for iOS and Android
- **Backend:** Supabase (Auth, Postgres + RLS, Edge Functions)
- **Analysis:** `analyze-scan` edge function — Open Food Facts + UPCitemdb registries, Gemini 2.5 Flash (JSON mode), deterministic organ-impact rule engine, per-plan field gating
- **On-device:** `mobile_scanner` live barcode scanning, photo capture/compression, local in-store barcode inventory (GS1 `2*` prefixes)

## Project structure

```
lib/
  app/         # router (auth gate), theme, session
  domain/      # pure Dart: barcode check digits, plan gating, rating, scan result
  data/        # Supabase client, DTOs, repositories, local stores
  features/    # auth, home, scan (+ result), history, content, shell, splash
  l10n/        # English strings (verbatim copy from design.md)
  widgets/     # shared brand/common widgets
supabase/
  migrations/  # 0001–0005: tables, RLS, leaderboard/quota functions, plan-column protection
  functions/analyze-scan/  # scan pipeline + organ rules + tests (Deno)
  tests/       # database tests (pgTAP)
```

## Prerequisites

- Flutter stable (Dart ^3.13.5)
- [Supabase CLI](https://supabase.com/docs/guides/cli) and Docker (for local backend)
- Deno (for edge-function tests)
- A **Gemini API key** (the only secret you must supply)

## Setup

1. **Install dependencies**
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs   # regenerate freezed DTOs after changes
   ```

2. **Start the local backend**
   ```bash
   supabase start
   supabase db push        # apply migrations
   ```
   Note the `API URL` and `anon key` printed by `supabase start` (or `supabase status`).

3. **Configure the Gemini key** (never commit it, never ship it in the app)
   ```bash
   cp supabase/.env.local.example supabase/.env.local
   # fill in GEMINI_API_KEY in supabase/.env.local   → used by `supabase functions serve`
   # for a deployed project instead:
   supabase secrets set GEMINI_API_KEY=...
   ```

4. **Serve the edge function locally**
   ```bash
   supabase functions serve analyze-scan --env-file supabase/.env.local
   ```

5. **Run the app**
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=http://localhost:54321 \
     --dart-define=SUPABASE_ANON_KEY=<anon key from supabase status>
   ```
   Without these dart-defines the app boots into a "config missing" screen by design.

## Useful commands

```bash
flutter analyze                          # lint — must stay clean
flutter test                             # unit + widget tests
deno test supabase/functions/analyze-scan/   # edge-function tests
supabase test db                         # database (pgTAP) tests
bash supabase/scripts/phase0_gate.sh     # backend acceptance gate: registry identity, cache consistency, credit rules
```

## Plans & gating

Free (30 scans) · Pro ₹200/mo (60) · Pro+ ₹500/mo (120) · Pro Max ₹1,200/mo (240 + body-impact map). Admin/founder/collaborator roles are unlimited. Quota is enforced **on the server only**; the app displays what the server returns. Payments are not live in v1 — plan cards are display-only (see PRD §9 and the open decisions in §16).
