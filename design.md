# RAPscanz — Design Specification (Flutter v1)

**Source of truth:** PRD.md (§6 Information architecture, §7 Functional requirements, §12 UX and visual design, §13 Non-functional requirements).
**Audience:** Implementing agent (Claude Code) and reviewers. All user-facing strings must be copied verbatim from the Copy Deck (§10 of this document) — never paraphrase.

---

## 1. Design language

- **Feel:** clean, health-conscious, high trust.
- **Surfaces:** white backgrounds and cards; charcoal body text.
- **Shadows:** hard offset shadows on marketing cards (a few pixels of offset, primary-green coloured) — *not* soft generic SaaS blur. Internal/app cards may use subtle elevation, but marketing/pricing cards keep the hard offset look.
- **Theme:** light only. No dark-mode-only design; the product is a light, health-green theme.
- **Layout:** phone-first. On tablets, same screens with a max content width (wider measure), centered.
- **Safe areas:** respected everywhere. Primary actions are full width.

## 2. Design tokens

### 2.1 Colors

| Token | Role | Notes |
| --- | --- | --- |
| `color.surface` | Screen/card background | White |
| `color.text` | Body text | Charcoal |
| `color.primary` | Deep green | Primary buttons, wordmark "scanz", active nav |
| `color.accent` | Fresh leaf green | Secondary accents, "okay" rating, gradient stop |
| `color.success` | Green | Rating `good`, score ring ≥ 70 |
| `color.warning` | Amber | Rating `caution`, score ring 40–69, severity `low` |
| `color.danger` | Red | Rating `avoid`, errors |
| `color.rose` | Rose/red | Score ring 0–39 |
| `color.severity.low` | Amber | Caution chip, organ harm low |
| `color.severity.medium` | Orange | Caution chip, organ harm medium |
| `color.severity.high` | Red | Caution chip, organ harm high |
| `color.benefit.*` | Greens (low→high) | Organ benefit markers |
| `color.veg` / `color.nonveg` / `color.vegan` | Dietary badge | Indian convention green/brown marks |

Exact hex values are finalized in `lib/app/theme.dart` during Phase 1; every semantic usage above must map to a token, not a raw color.

### 2.2 Typography

Bundled OFL fonts (declared in `pubspec.yaml`, no runtime fetch):

| Token | Face | Usage |
| --- | --- | --- |
| `font.display` | Bricolage Grotesque (OFL) | Headlines, health score numerals, pricing |
| `font.body` | Plus Jakarta Sans (OFL) | Body, labels, inputs, bullets |

If a face is unavailable in the bundled set, use the closest SIL-licensed equivalent approved for the app. Dynamic type must scale up to a large size without clipping the score ring.

### 2.3 Logo & brand

- **Mark:** rounded square, green-to-teal gradient, white scanner-reticle corners, a leaf, horizontal laser sweep.
- **Wordmark:** "RAP" in charcoal + "scanz" in primary green → **RAPscanz**.
- **Positioning line:** *Know what's actually in your food.*
- Splash shows the mark + wordmark.

### 2.4 Motion

- Scan-running state: short scan-chamber / laser-sweep animation over the input preview (the web preview is ~6 s; real wait is network-bound — loop the animation, don't time it). Must not block the UI thread.
- Keep all other motion minimal (standard material transitions).

## 3. Navigation & information architecture

### 3.1 Unauthenticated (no bottom nav)

| Route | Screen |
| --- | --- |
| `/` | Splash → routes to Home or Scan |
| `/home` | Home / marketing |
| `/auth` | Sign in / Create account (toggle) |
| `/leaderboard` | Leaderboard (public) |
| `/trust` | Trust & privacy |
| `/guides/healthy-snacks` | Healthy snacks guide |

### 3.2 Authenticated (bottom navigation, 5 tabs)

| # | Tab | Icon | Route | Notes |
| --- | --- | --- | --- | --- |
| 1 | Scan | scan | `/scan` | Default after sign-in |
| 2 | History | history | `/history` | |
| 3 | Weekly | flame | `/weekly` | |
| 4 | Leaderboard | trophy | `/leaderboard` | Same public screen, reachable signed-in |
| 5 | Profile | person | `/profile` | Sign out lives here |

Secondary routes: `/history/:id` (scan detail), Plans sheet (modal, from quota/upgrade entry points).

**Session gate:** existing session skips auth → Scan. Sign out clears session → Home. Signed-out users hitting Scan/History/Weekly/Profile are redirected to `/auth`; Leaderboard, Home, Trust, and the guide stay reachable (PRD §14.14).

## 4. Screen specifications

### 4.1 Splash
Brand mark + wordmark centered on white. Resolve session, then route (Home if signed out, Scan if signed in).

### 4.2 Home (marketing)
- Headline (display font): **Know what's actually in your food.**
- Supporting copy: snap a label, paste ingredients, or scan a barcode; get the good, the bad, and the chemicals worth a second look.
- Primary CTA (full width): **Start scanning** → `/auth` if signed out, `/scan` if signed in.
- "How it works" — three numbered steps (hard-offset cards):
  1. Paste or photograph the ingredient list.
  2. Or scan the barcode and pull the product from the open food database.
  3. Get the verdict: advantages, disadvantages, chemical cautions.
- Pricing cards (§5) — all four tiers + unlimited note.
- Footer: **For information only — not medical advice.**
- Entry points: Leaderboard, Trust & privacy, healthy-snacks guide.

### 4.3 Auth
- Toggle between **Sign in** and **Create account** on one screen.
- Email + password fields. Minimum password length 6 (client hint; server is authoritative).
- One account per email. Errors from the provider shown in a toast or inline error (e.g. invalid credentials, weak password, email already registered).
- On success → `/scan`. Passwords are never stored by the app.

### 4.4 Scan (default tab)

**Header chip** (always visible): current plan + remaining scans.
- Paid/privileged: `{Plan} · {remaining} of {limit} scans left`
- Unlimited role: `{Plan} · Unlimited scans`
- At zero remaining: block new scans, show the upgrade card. Local in-store lookups stay available.

**Three input modes** (segmented control or tabs within the screen) + one primary button **Scan & analyze**:

1. **Text**
   - Multiline field, placeholder: *Paste the ingredient list from the back of the packet…*
   - Empty submit → error: *Paste the ingredient list first.*
   - Server cap 10,000 chars — show a counter approaching the cap.
2. **Photo**
   - Take a photo (rear camera) or pick from library.
   - Reject > 5 MB on device: *Image must be under 5MB.*
   - Preview thumbnail with a remove (✕) control.
   - Compress before upload so a typical label photo stays well under 5 MB.
3. **Barcode**
   - Numeric field; strip spaces and non-digits as the user types.
   - Accepted lengths: 8 (EAN-8), 12 (UPC-A), 13 (EAN-13), 14 (ITF-14), each with valid GS1 check digit.
   - Invalid check digit error (verbatim, see Copy Deck).
   - **Live camera scanner** button (mobile requirement): opens scanner overlay reading EAN-8/13, UPC-A, ITF-14; fills the field and submits.
   - A code starting with `2` (8–14 digits) is an in-store code → local inventory flow (§6), never a server call, no credit spent.

**While a scan runs**
- Primary button disabled; laser/scanner animation visible.
- Barcode copy: *Looking up barcode & consulting AI registry…*
- Text/photo copy: *Analyzing your scan…* / *Analyzing…*
- Photo resolved to barcode: toast *Photo scanned — barcode detected & analyzed.*
- Other success: toast *Scan complete.*

**Error toasts** (verbatim, Copy Deck §10): quota exhausted, rate limited, AI unavailable, AI credits exhausted, registry miss, no-network (*You need a connection to analyse a product.* — local inventory still works).

### 4.5 Scan result

Render blocks **in this exact order** (PRD §7.4). All tiers see un-gated blocks; gated blocks show locked teasers below their tier.

1. **Verdict header**
   - Rating chip: `good` → "Good choice" (success green) · `okay` → "Okay-ish" (accent leaf) · `caution` → "Caution" (amber) · `avoid` → "Better avoid" (danger red). Label text always accompanies color.
   - Product name (display font); brand line: `{brand}`, "by {parent company}", category.
   - Veg / vegan / non-veg mark on the header for Pro Max when type is known.
   - HealthScoreRing (§7.1) + score label + one decimal out of 10 (`score / 10`).
2. **Summary** — 1–2 sentences.
3. **For you** — `personalAdvice` with a heart icon. Hidden entirely when empty.
4. **Calories** — "~{n} kcal per serving."
5. **I ate this** — button; disabled until `scanId` exists; success state "Added to this week."
6. **Dietary classification** — Pro Max: badge + `dietaryReason`. Others: locked card "Veg · Non-Veg · Vegan" / "Unlock dietary classification (with the specific ingredient reason)."
7. **Advantages / Disadvantages** — side-by-side on wide layouts, stacked on phone; 3–6 bullets each; empty state "None notable."
8. **Safe consumption guide** — Pro+ and above, when `consumptionTip` present: safe/day, upper limit, source.
9. **Chemical & ingredient cautions** — each card: ingredient, optional percentage, concern, optional formula & scientific name, severity chip (`low`/`medium`/`high` with the word, not color alone). Empty: "No flagged chemicals."
10. **What over-consumption can cause** — Pro Max, when any risk list non-empty. Five groups: illnesses & conditions, addiction patterns, chronic damage, temporary effects, organ-specific damage.
11. **Body-impact map** — always present. Below Pro Max: blurred/locked preview + "Upgrade to Pro Max" (never reveal organ names/severities/reasons in teaser). Pro Max: two silhouettes (§7.2).
12. **Rate this product** — 1–5 stars, "Would you buy this again?" (Yes / Maybe / No), optional comment ≤ 1,000 chars. One feedback row per user per scan; re-saving updates it. Thank-you state after submit.

**Result footer / first-result-of-session:** persistent disclaimer — informational, not medical advice (also on Home).

### 4.6 History
- Title "Scan history", subtitle "Everything you've scanned with RAPscanz."
- Newest first, up to 50 rows.
- Row: rating dot (with semantic label for a11y), product name, date/time, scan type, rating, two-line summary, small HealthScoreRing.
- Empty: "No scans yet" + button to Scan.
- Tap → detail: full saved analysis (same blocks as 4.5, no re-run of the model) + I ate this.
- Missing scan: "Scan not found" with back link.
- Opens from cache when offline, refreshes when online.

### 4.7 Weekly
- Title "This week", subtitle "Calories from the foods you marked as eaten."
- Window: last 7 local calendar days including today, from local midnight.
- Header: 7-day total kcal + average kcal/day (total / 7).
- Seven bars labelled with weekday short names; heights relative to busiest day.
- Entry list: product name, consumed-at timestamp, kcal, delete (removes that consumption row only, not the scan).
- Empty: "Nothing logged yet this week" + link to Scan.

### 4.8 Leaderboard (public)
- Copy: "Top users by average health score (min. 3 scans)."
- Rows: rank (🥇🥈🥉 for 1–3, else `#n`), `@username`, average score (rounded), scan count. Cap 50.
- Empty: "No qualifying users yet. Be the first — set a username and scan some food!"
- Never shows health profile fields. Viewable signed out.

### 4.9 Profile
Two sections + sign out.

**Display name**
- Username field: 3–20 chars, letters/numbers/underscore, unique case-insensitive.
- Shown on leaderboard as `@username`.
- Errors (verbatim): "Username must be 3–20 chars (letters, numbers, underscore)." / "That username is taken."

**Health info** (optional, private)

| Field | Control | Rules |
| --- | --- | --- |
| Gender | Dropdown | Prefer not to say / Female / Male / Non-binary / Other → stored `""` / `female` / `male` / `non_binary` / `other` |
| Age | Number | Integer 1–129 |
| Weight | Number (kg) | > 0 and < 500 |
| Height | Number (cm) | > 0 and < 300 |
| Conditions | Text | Max 500 chars; example hint: diabetes, hypertension, PCOS, lactose intolerance |
| Allergies | Text | Max 500 chars; example hint: peanuts, gluten, soy |

- When weight + height set, show live BMI = weight / (height m)², one decimal.
- Privacy copy: stored privately; never shown on the leaderboard; used to personalise scan advice.
- Save button → success toast "Profile saved!"

### 4.10 Plans sheet
- Modal sheet listing the four plan cards + current plan highlight (see §5).
- Out-of-scans entry points show the same upgrade message as web (Copy Deck).
- **No live checkout in v1:** upgrade buttons explain payments are coming; never pretend a purchase succeeded. No embedded web Razorpay checkout on iOS (App Store/Play billing rules — open decision, PRD §16).

### 4.11 Trust & privacy
Static page in the product's voice covering (PRD §7.10): hashed passwords & one account per email; RLS owner-only access; what is collected; how it's used; no sale of personal data; HTTPS; plan/quota columns not user-editable; server-side quota and leaderboard aggregation; session storage only, no third-party ad trackers; subprocessors (hosting/DB and an AI gateway); editing health profile in-app; account-deletion requests go to the team; closing line — general informational analysis, not a medical service.

### 4.12 Healthy snacks guide
In-app page (or trusted web view): **"The Perfect Healthy Snack: What to Look for on the Label."** Covers a short label-reading rule, how to read an ingredient list, additives worth a second look, what a good snack looks like, and a prompt to scan with RAPscanz. No sign-in required.

## 5. Plan & pricing presentation (PRD §8)

| | Free | Pro | Pro+ | Pro Max | Unlimited (role) |
| --- | --- | --- | --- | --- | --- |
| Price | ₹0 | ₹200 / mo | ₹500 / mo | ₹1,200 / mo | Not sold |
| Scans | 30 total | 60 | 120 | 240 | Unlimited |
| Analysis (text/photo/barcode), score, summary, calories, adv/disadv, cautions, personal advice, history/weekly/leaderboard/feedback | ✓ | ✓ | ✓ | ✓ | ✓ |
| Estimated % on cautions | — | in concern text | `percentage` field | ✓ | ✓ |
| Chemical formula & scientific name | — | — | ✓ | ✓ | ✓ |
| Safe consumption guide | — | — | ✓ | ✓ | ✓ |
| Over-consumption risk profile | — | — | — | ✓ | ✓ |
| Dietary classification | Locked teaser | Locked teaser | Locked teaser | ✓ | ✓ |
| Body-impact map | Locked teaser | Locked teaser | Locked teaser | ✓ | ✓ |

Client rule: treat `plan == pro_max` **or** `isUnlimited` / `plan == unlimited` as Pro Max features unlocked. Expired paid plan (`plan_expires_at` in past) behaves as Free. Hide locked sections even if a stale payload contains them.

## 6. Local / in-store barcode flow (PRD §7.5)

- Device-side detection before any server call: digits only, length 8–14, starts with `2`.
- No API call, no credit spent.
- Known code → saved card: name, optional price, optional weight, barcode, "Saved on this device."
- Unknown code → dialog: item name (required), price (optional), weight/size (optional) → save to on-device storage.
- Removing an item deletes it from that device only.
- Photo OCR returning such a code → same flow + toast: "Barcode {code} read from photo — looks like a local/in-store item."
- Storage key `rapscanz.localBarcodes.v1`, shape `{ [barcode]: { name, price?, weight?, savedAt } }`. No cross-device sync in v1.

## 7. Key components

### 7.1 HealthScoreRing
Circular progress ring 0–100 (clamped), with numeric score and label:

| Score | Ring colour | Label |
| --- | --- | --- |
| 85–100 | Green | Excellent for you |
| 70–84 | Green | Healthy choice |
| 40–69 | Amber | Okay in moderation |
| 20–39 | Rose | Eat rarely |
| 0–19 | Rose | Better avoid |

Also show score / 10 with one decimal. Small variant for history rows. Must not clip at large dynamic type sizes. Expose label + score as semantics text.

### 7.2 BodyDamageMap (Pro Max)
- Two front-facing human silhouettes: **Harms** (amber/orange/red by severity) and **Benefits** (greens by severity). Render as a Flutter `CustomPainter` or SVG asset with tappable regions.
- Allowed organ keys: brain, eyes, teeth, throat, heart, lungs, liver, stomach, pancreas, kidneys, intestines, skin, bones.
- Marker data: `part`, `severity` (`low|medium|high`), `reason`, optional `trigger`. Tap a highlighted organ → bottom sheet/tooltip with reason + trigger.
- Anatomy: subject's left is viewer's right; the heart sits on the subject's left.
- Empty side: still draw the silhouette + "No specific organ harm detected" / "No specific organ benefit detected."
- Locked state (< Pro Max): blurred preview, static teaser image is enough, "Upgrade to Pro Max", no organ names/severities/reasons.
- Accessibility: also render the organ list as text (part, severity word, reason, trigger) so screen readers get identical information.

### 7.3 Other shared components
- **RatingChip** (label + color, never color alone).
- **CautionCard** with severity chip (word + color).
- **DietaryBadge** (veg/non-veg/vegan marks per Indian convention).
- **QuotaChip** (plan + remaining; unlimited variant).
- **UpgradeCard / LockedTeaser** (per-section locked states).
- **ScannerOverlay** (live barcode camera with reticle).
- **LaserScanAnimation** (analysis-in-progress).
- **Toast** helper (short success/failure), **inline warning cards** for quota and local-barcode notices.

## 8. Accessibility requirements (PRD §12, §14.15)

- Rating and severity are never colour alone — always text label + colour.
- Body map exposes the full text list equivalent.
- VoiceOver/TalkBack can read verdict, score label, and each caution.
- Dynamic type up to a large size without clipping the score ring.
- Camera permission denial explains how to enable it in Settings **and** still allows paste + manual barcode entry.
- All interactive elements ≥ 44×44 pt touch targets; semantic labels on icon-only buttons.

## 9. States inventory

Empty, loading, and error states must exist for: history (list + detail), weekly, leaderboard, scan (no network, quota, rate limit, AI errors, registry miss, invalid barcode, empty text, oversize image), scan detail (missing scan), profile save, feedback submit, camera permission denied.

## 10. Copy deck (verbatim strings — do not paraphrase)

| Context | String |
| --- | --- |
| Positioning line | Know what's actually in your food. |
| Home supporting copy | Snap a label, paste ingredients, or scan a barcode — get the good, the bad, and the chemicals worth a second look. |
| Home CTA | Start scanning |
| Disclaimer (Home footer / result footer) | For information only — not medical advice. |
| In-product disclaimer | RAPscanz is informational. It is not medical advice. |
| Quota chip (paid) | {Plan} · {remaining} of {limit} scans left |
| Quota chip (unlimited) | {Plan} · Unlimited scans |
| Scan primary button | Scan & analyze |
| Text placeholder | Paste the ingredient list from the back of the packet… |
| Empty text error | Paste the ingredient list first. |
| Oversize image | Image must be under 5MB. |
| Invalid check digit | Invalid or fake barcode. Real product barcodes are 8, 12, 13, or 14 digits with a valid check digit (EAN/UPC). Please re-enter or rescan. |
| Registry miss | Product not found in the Open Food Facts / GS1 registry for barcode {code}. We don't guess product identity from barcode prefixes — please scan the label photo or paste the ingredients instead. |
| Scanning (barcode) | Looking up barcode & consulting AI registry… |
| Scanning (text/photo) | Analyzing your scan… / Analyzing… |
| Photo → barcode toast | Photo scanned — barcode detected & analyzed. |
| Success toast | Scan complete. |
| Quota exhausted | You've used all your scans for this cycle. Upgrade to Pro (₹200/mo · 60), Pro+ (₹500/mo · 120) or Pro Max (₹1200/mo · 240 + 3D body-damage map) to keep scanning. |
| Rate limit | Too many scans right now. Please try again in a moment. |
| AI unavailable | The analysis service is temporarily unavailable. Please try again. |
| AI credits exhausted | AI credits exhausted. Please contact the app owner. |
| No network | You need a connection to analyse a product. |
| Local barcode from photo toast | Barcode {code} read from photo — looks like a local/in-store item. |
| Local saved card | Saved on this device. |
| Rating labels | Good choice / Okay-ish / Caution / Better avoid |
| Score labels | Excellent for you / Healthy choice / Okay in moderation / Eat rarely / Better avoid |
| Calories line | ~{n} kcal per serving. |
| I ate this (success) | Added to this week. |
| Advantages/disadvantages empty | None notable. |
| Cautions empty | No flagged chemicals. |
| Dietary locked card | Veg · Non-Veg · Vegan — Unlock dietary classification (with the specific ingredient reason). |
| Body map locked | Upgrade to Pro Max |
| Body map empty harm | No specific organ harm detected |
| Body map empty benefit | No specific organ benefit detected |
| Feedback prompt | Would you buy this again? (Yes / Maybe / No) |
| History title / subtitle | Scan history / Everything you've scanned with RAPscanz. |
| History empty | No scans yet |
| Scan detail missing | Scan not found |
| Weekly title / subtitle | This week / Calories from the foods you marked as eaten. |
| Weekly empty | Nothing logged yet this week |
| Leaderboard copy | Top users by average health score (min. 3 scans). |
| Leaderboard empty | No qualifying users yet. Be the first — set a username and scan some food! |
| Username format error | Username must be 3–20 chars (letters, numbers, underscore). |
| Username taken | That username is taken. |
| Profile saved toast | Profile saved! |
| Guide title | The Perfect Healthy Snack: What to Look for on the Label |
| Billing placeholder | Payments will be enabled soon |
