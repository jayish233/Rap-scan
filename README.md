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
  features/    # auth, home, scan (+ result, local inventory), history, weekly,
               # leaderboard, profile, plans, content, shell, splash
  l10n/        # English strings (verbatim copy from design.md)
  widgets/     # shared brand/common widgets
supabase/
  migrations/  # 0001–0006: tables, RLS, leaderboard/quota functions, plan-column
               # protection, consumption filled from the scan row
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
   Local ports are shifted to **553xx** (API `http://127.0.0.1:55321`) in `supabase/config.toml`.

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
     --dart-define=SUPABASE_URL=http://127.0.0.1:55321 \
     --dart-define=SUPABASE_ANON_KEY=<anon key from supabase status>
   # or keep them in a git-ignored file (see config/example.json):
   flutter run --dart-define-from-file=config/local.json           # iOS simulator
   flutter run --dart-define-from-file=config/local.android.json   # Android emulator (10.0.2.2)
   ```
   Without these dart-defines the app boots into a "config missing" screen by design.

## Useful commands

```bash
flutter analyze                          # lint — must stay clean
flutter test                             # unit, widget + accessibility tests
deno test supabase/functions/analyze-scan/   # edge-function tests
supabase test db                         # database (pgTAP) tests
bash supabase/scripts/phase0_gate.sh     # backend acceptance gate: registry identity, cache consistency, credit rules
```

### On-device acceptance gates (PRD §14)

Run against a booted simulator (`xcrun simctl list devices`) with the local backend and edge function serving.

| Gate | Command | Needs live Gemini |
| --- | --- | --- |
| Sign-up → Scan, sign-out, public pages (§14.1, §14.14) | `flutter test integration_test/phase1_gate_test.dart --dart-define-from-file=config/local.json -d <id>` | no |
| Text + barcode scans, cache, no-credit validation, history (§14.2–5) | `flutter test integration_test/phase2_gate_test.dart …` | yes |
| Photo → barcode / image analysis, > 5 MB rejected (§14.7) | `flutter test integration_test/phase3_gate_test.dart …` | yes |
| In-store code, no credit, survives restart (§14.6) | `tool/phase3_restart_gate.sh <id>` | no |
| Plan gating, expired plan, unlimited role (§14.11–12) | `tool/phase4_gate.sh <id>` | no |
| Profile, weekly, leaderboard, feedback (§14.8–10, §14.13) | `flutter test integration_test/phase5_gate_test.dart …` | no |

`flutter test` uninstalls the app when it finishes (wiping its storage), so the restart gate uses `flutter drive --keep-app-running`.

## Plans & gating

Free (30 scans) · Pro ₹200/mo (60) · Pro+ ₹500/mo (120) · Pro Max ₹1,200/mo (240 + body-impact map). Admin/founder/collaborator roles are unlimited. Quota is enforced **on the server only**; the app displays what the server returns. Payments are not live in v1 — plan cards are display-only (see PRD §9 and the open decisions in §16).
