# RAPscanz — Product Requirements Document

**Product:** RAPscanz mobile app (iOS and Android)
**Document purpose:** Build a cross-platform Flutter app that reproduces the existing RAPscanz web product.
**Source of truth:** The current web app in this repository (TanStack Start + Supabase).
**Status:** Draft for implementation
**Audience:** Product, design, and Flutter engineering

---

## 1. Summary

RAPscanz tells a shopper what is actually in a packaged food. The user pastes an ingredient list, photographs a label, or enters a barcode. The app returns a plain-English verdict: a 0–100 health score, a rating, calories per serving, advantages, disadvantages, chemical cautions, and advice tailored to the user’s health profile.

The product is built for Indian packaged foods (Amul, Britannia, Parle, Haldiram’s, Mother Dairy, MTR, Tata, ITC, Patanjali, Nestlé India, and similar) and for international brands. Dietary classification follows Indian convention: egg is non-vegetarian.

The Flutter app is a native client of the same product. Scan analysis, quota, and shared barcode results stay on the server. The phone handles camera, barcode capture, local in-store inventory, and presentation.

**Disclaimer, shown in the product:** RAPscanz is informational. It is not medical advice.

**Positioning line:** Know what’s actually in your food.

---

## 2. Problem and outcome

Shoppers cannot reliably read ingredient lists, additive codes, parent companies, or how a product conflicts with diabetes, hypertension, PCOS, allergies, or weight goals. RAPscanz turns a label or barcode into a consistent, personal verdict in one action.

**Success for v1 of the mobile app**

- A signed-in user can complete a scan from text, camera, or barcode and see the same result shape the web app produces.
- The same barcode produces the same product identity and nutrition analysis for every user.
- Free, Pro, Pro+, and Pro Max gating matches the matrix in section 8.
- Scan history, “I ate this,” the 7-day calorie view, profile, and public leaderboard work against the existing Supabase data.
- iOS and Android share one Flutter codebase.

---

## 3. Users

| User | Need |
| --- | --- |
| Everyday shopper | A fast verdict at the store shelf, in English, without reading a long label. |
| Health-conscious user | Advice that accounts for age, BMI, conditions, and allergies. |
| Vegetarian / vegan shopper (India) | Veg, non-veg, or vegan classification with the ingredient that decided it. |
| Power user (Pro Max) | Organ-level harm and benefit, over-consumption risk, and structured chemical detail. |
| Competitive user | A public username and a place on the health-score leaderboard. |
| Privileged account | Admin, founder, or collaborator. Unlimited scans and Pro Max features. |

The app has no separate admin UI. Privileged access is granted in the database (`user_roles`).

---

## 4. Scope

### In scope for the Flutter v1

- Email and password sign-up and sign-in
- Landing / marketing, trust & privacy, healthy-snacks guide
- Three scan inputs: pasted ingredients, label photo, barcode
- Full scan result, including plan-gated sections
- Scan history (list and detail) and “I ate this”
- Weekly calorie log
- Profile and personalised advice
- Public leaderboard
- Plan display, remaining scans, and upgrade messaging
- On-device local inventory for in-store barcodes
- Offline-tolerant reading of already loaded screens where practical; scanning requires network

### Explicitly out of scope for v1

- A new analysis engine on the device
- Guessing a product identity from a barcode prefix when registries miss
- Social features beyond the public leaderboard
- Family accounts, meal plans, grocery lists, or restaurant menus
- Web checkout inside the app until a store-compliant billing path is chosen (see section 9)
- Dark-mode-only design; the current product is a light, health-green theme
- Editing or deleting past scans (the database allows delete; the current UI does not expose it)

---

## 5. Product principles

1. **Plain language.** Summaries, cautions, and advice are short sentences a non-expert can act on.
2. **Same barcode, same answer.** Product name, brand, parent company, and category come from the food registry. Nutrition analysis is cached per barcode.
3. **Identity is never invented from a barcode.** If Open Food Facts and UPCitemdb both miss the code, the scan fails with a clear message and the user is sent to photo or pasted ingredients.
4. **Personal data stays private.** Health fields never appear on the leaderboard.
5. **Gentle, specific, non-clinical.** Advice can flag allergens and conflicts with stated conditions. It does not diagnose or prescribe.
6. **Quota is enforced on the server.** The client only displays the remaining count.

---

## 6. Information architecture

### Unauthenticated

| Screen | Purpose |
| --- | --- |
| Splash / intro | Brand mark: leaf inside a scanner reticle, wordmark **RAPscanz** (RAP + green “scanz”). |
| Home | Value proposition, how it works, pricing, link to the snack guide and leaderboard. |
| Sign in / Create account | Email + password. Toggle between modes. |
| Leaderboard | Public. Top users by average health score. |
| Trust & privacy | Data, security, cookies, contact. |
| Guide: healthy snacks | Static article, “The Perfect Healthy Snack.” |

### Authenticated

Primary navigation (bottom navigation on mobile; the web app uses a top bar):

1. **Scan** — default after sign-in
2. **History**
3. **Weekly**
4. **Leaderboard**
5. **Profile**

Sign out is available from Profile (and from the header on web).

Secondary:

- Scan detail (`/history/:id` equivalent)
- Upgrade / plan explanation (today the web “Upgrade” links go to Profile; mobile should open a dedicated Plans sheet — see section 9)

---

## 7. Functional requirements

### 7.1 Authentication

- Sign up and sign in with email and password. Minimum password length: 6.
- One account per email.
- On success, open Scan.
- If a session already exists, skip auth and open Scan.
- Sign out clears the session and returns to Home.
- Persist the session securely (Supabase auth; Flutter secure storage for the refresh token).
- Passwords are never stored by the app.

**Errors:** Show the provider message in a toast or inline error. Examples: invalid credentials, weak password, email already registered.

### 7.2 Home

- Headline: “Know what’s actually in your food.”
- Supporting copy: snap a label, paste ingredients, or scan a barcode; get the good, the bad, and the chemicals worth a second look.
- Primary action: Start scanning (routes to auth if signed out, Scan if signed in).
- How it works, three steps:
  1. Paste or photograph the ingredient list.
  2. Or scan the barcode and pull the product from the open food database.
  3. Get the verdict: advantages, disadvantages, chemical cautions.
- Pricing cards from section 8.
- Footer: “For information only — not medical advice.”
- Entry points: Leaderboard, Trust, healthy-snacks guide.

### 7.3 Scan — inputs

The Scan screen has three modes and one primary button, **Scan & analyze**.

Show the current plan and remaining scans in a chip:

- Paid or privileged: `{Plan} · {remaining} of {limit} scans left`
- Unlimited role: `{Plan} · Unlimited scans`
- At zero remaining: block new scans and show the upgrade card. Local in-store lookups stay available.

**Text**

- Multiline field. Placeholder: “Paste the ingredient list from the back of the packet…”
- Submit on the primary button. Empty text shows “Paste the ingredient list first.”
- Server accepts up to 10,000 characters.

**Photo**

- Take a photo (rear camera) or pick from the library.
- Reject files over 5 MB: “Image must be under 5MB.”
- Show a preview with a remove control.
- The server first tries to read a barcode from the image (OCR). A valid EAN/UPC is then analysed exactly like a typed barcode.
- If OCR finds a GS1 in-store code (see 7.5), hand the code to local inventory and do not run a global lookup.
- If no valid barcode is found, analyse the label image directly (ingredients visible in the photo).

**Barcode**

- Numeric field. Strip spaces and non-digits as the user types.
- Accepted symbologies: EAN-8 (8), UPC-A (12), EAN-13 (13), ITF-14 (14), each with a valid GS1 check digit.
- A 12-digit UPC that fails is retried server-side as EAN-13 with a leading `0`.
- Invalid check digit: “Invalid or fake barcode. Real product barcodes are 8, 12, 13, or 14 digits with a valid check digit (EAN/UPC). Please re-enter or rescan.”
- On mobile, add a live camera scanner (EAN-8, EAN-13, UPC-A, ITF-14) that fills this field and submits. The web app only has manual entry; live scan is a mobile requirement because it is the natural phone equivalent of the barcode tab.
- Unknown in both registries: “Product not found in the Open Food Facts / GS1 registry for barcode {code}. We don't guess product identity from barcode prefixes — please scan the label photo or paste the ingredients instead.”

**While a scan runs**

- Disable the button.
- Show a scanner animation.
- Barcode copy: “Looking up barcode & consulting AI registry…”
- Text/photo copy: “Analyzing your scan…” or “Analyzing…”
- Photo that resolved to a barcode: toast “Photo scanned — barcode detected & analyzed.”
- Other success: toast “Scan complete.”

**Quota errors**

- “You've used all your scans for this cycle. Upgrade to Pro (₹200/mo · 60), Pro+ (₹500/mo · 120) or Pro Max (₹1200/mo · 240 + 3D body-damage map) to keep scanning.”
- Rate limit: “Too many scans right now. Please try again in a moment.”
- AI unavailable: “The analysis service is temporarily unavailable. Please try again.”
- AI credits exhausted: “AI credits exhausted. Please contact the app owner.”

Each successful analysis consumes one scan credit **before** the model call, including cache hits. A failed validation (bad barcode, empty input) consumes nothing. A local in-store lookup consumes nothing.

### 7.4 Scan — result

Render in this order. All tiers see the un-gated blocks. Gated blocks follow section 8.

1. **Verdict header**
   - Rating chip: `good` → “Good choice”; `okay` → “Okay-ish”; `caution` → “Caution”; `avoid` → “Better avoid.”
   - Colours: success green, accent leaf, warning amber, danger red.
   - Product name.
   - Brand, “by {parent company}”, category.
   - Veg / vegan / non-veg mark on the header for Pro Max when the type is known.
   - Health score ring, 0–100, plus label and score out of 10 (see 7.4.1).
2. **Summary** — 1–2 sentences.
3. **For you** — `personalAdvice` when the profile produced any. Heart icon. Hidden when empty.
4. **Calories** — “~{n} kcal per serving.”
5. **I ate this** — logs consumption for this scan. Disabled until a `scanId` exists. Success state: “Added to this week.”
6. **Dietary classification** — Pro Max, or a locked teaser.
7. **Advantages** and **Disadvantages** — side by side on wide layouts, stacked on a phone. 3–6 bullets each. Empty state: “None notable.”
8. **Safe consumption guide** — Pro+ and above, when `consumptionTip` is present. Safe/day, upper limit, source.
9. **Chemical & ingredient cautions** — ingredient, optional percentage, concern, optional formula and scientific name, severity chip (`low` / `medium` / `high`). Empty: “No flagged chemicals.”
10. **What over-consumption can cause** — Pro Max, when any risk list is non-empty. Five groups: illnesses & conditions, addiction patterns, chronic damage, temporary effects, organ-specific damage.
11. **Body-impact map** — always present. Locked teaser below Pro Max. Pro Max shows harm and benefit silhouettes (see 7.4.2).
12. **Rate this product** — 1–5 stars, “Would you buy this again?” (Yes / Maybe / No), optional comment up to 1,000 characters. One feedback row per user per scan; saving again updates it. Thank-you state after submit.

#### 7.4.1 Health score

| Score | Ring colour | Label |
| --- | --- | --- |
| 85–100 | Green | Excellent for you |
| 70–84 | Green | Healthy choice |
| 40–69 | Amber | Okay in moderation |
| 20–39 | Rose | Eat rarely |
| 0–19 | Rose | Better avoid |

Clamp to 0–100. Also show one decimal out of 10 (score / 10).

Scoring intent (model instructions, not a client formula): penalise ultra-processing, high sugar, sodium, saturated fat, trans fat, and artificial additives; reward whole ingredients, fibre, protein, and healthier fats. Calories are per typical serving (examples used by the model: 30 g chips, 250 ml drink, 1 biscuit, ~12 g chocolate). Use 0 only for true zero-calorie products such as water.

Category must stay specific. An energy bar is not a chocolate bar. A chikki is not an extruded snack. If the input is too unclear, the product name is “Unidentified product,” category is “Unknown,” and the summary says the image or barcode was not clear enough.

#### 7.4.2 Body-impact map

Two front-facing human silhouettes:

- **Harms** — organs at risk. Severity colours: low amber, medium orange, high red.
- **Benefits** — organs that gain. Severity colours: low to high greens.

Allowed organ keys: brain, eyes, teeth, throat, heart, lungs, liver, stomach, pancreas, kidneys, intestines, skin, bones.

Each marker has `part`, `severity` (`low` | `medium` | `high`), `reason`, and an optional `trigger` (the nutrient or ingredient). Tapping a highlighted organ shows the reason and trigger. The subject’s left side is on the viewer’s right (anatomical front view). The heart sits on the subject’s left.

If a side has no organs, still draw the silhouette and say “No specific organ harm detected” or “No specific organ benefit detected.”

When barcode nutrition data exists, organ impact is **rule-based and deterministic** from per-100 g nutriments and ingredient text (sugar, saturated fat, salt, fibre, protein, micronutrients, and named ingredients such as palm oil, trans fat, MSG, artificial sweeteners, caffeine, alcohol, azo colours, nitrites, probiotics, omega-3, whole grains). The same inputs always yield the same organs. Otherwise the model supplies `bodyDamage` and `bodyBenefit`.

Below Pro Max, show a blurred/locked preview and “Upgrade to Pro Max.” Do not reveal organ names, severities, or reasons in the teaser.

#### 7.4.3 Dietary classification

| Value | Label | Meaning |
| --- | --- | --- |
| `vegan` | Vegan | Entirely plant-based. No dairy, honey, egg, or animal-derived additives. |
| `veg` | Vegetarian | Lacto-vegetarian: plants plus milk, butter, ghee, cheese, whey, casein, or honey. No non-veg ingredients. |
| `non-veg` | Non-Vegetarian | Meat, poultry, fish, seafood, gelatin, lard/tallow, animal rennet, carmine/cochineal (E120), shellac (E904), or egg. |
| `unknown` | Unknown | Ingredient list unreadable and brand/category cannot be inferred. Avoid this when a reasonable inference exists. |

Always include `dietaryReason`, for example “Contains milk solids and butter (lacto-vegetarian).”

Indian convention: egg is non-veg. Mono- and diglycerides are treated as vegetarian unless the source is clearly animal. Vitamin D3 from lanolin stays vegetarian; D3 from lichen is vegan. Gelatin is non-veg. L-cysteine is non-veg unless labelled microbial. Rennet is non-veg unless labelled microbial or vegetable.

Pro Max sees the badge and the reason. Other plans see a locked card: “Veg · Non-Veg · Vegan” and “Unlock dietary classification (with the specific ingredient reason).”

### 7.5 Local / in-store barcodes

GS1 prefixes 20–29 are restricted-circulation / in-store codes. They are not in global product databases.

- Detect on the device before calling the server: digits only, length 8–14, and the code starts with `2`.
- Do not call the analysis API and do not spend a credit.
- If this device already saved the code, show the saved card: name, optional price, optional weight, barcode, and “Saved on this device.”
- If unknown, open a dialog: item name (required), price (optional), weight/size (optional). Save to on-device storage.
- Removing an item deletes it from that store only.
- A photo OCR that returns one of these codes uses the same flow. Toast: “Barcode {code} read from photo — looks like a local/in-store item.”
- Storage key equivalent: `rapscanz.localBarcodes.v1`. Shape: `{ [barcode]: { name, price?, weight?, savedAt } }`.
- This inventory does not sync across devices in v1.

### 7.6 History

- Title: “Scan history.” Subtitle: “Everything you've scanned with RAPscanz.”
- Newest first, up to 50 scans.
- Each row: rating dot, product name, date/time, scan type, rating, two-line summary, small health-score ring.
- Empty state: “No scans yet” and a button to Scan.
- Tap opens detail: the saved analysis (verdict, summary, personal advice, calories, advantages, disadvantages, consumption tip, cautions) and **I ate this**.
- Detail does not need to re-run the model.
- Missing scan: “Scan not found” with a back link.

### 7.7 Weekly intake

- Title: “This week.” Subtitle: “Calories from the foods you marked as eaten.”
- Window: the last 7 local calendar days, including today, from local midnight.
- Header: 7-day total kcal and average kcal/day (total / 7).
- Seven bars labelled with the weekday short name. Bar height is relative to the busiest day.
- Entry list: product name, consumed-at timestamp, kcal, delete.
- Delete removes that consumption row only, not the scan.
- Empty: “Nothing logged yet this week” and a link to Scan.
- Logging is explicit. Opening a scan does not count as eating it.
- Calories logged are the scan’s per-serving estimate. Multiple logs of the same scan are allowed (the user ate it again).

### 7.8 Leaderboard

- Public. No sign-in required to view.
- Copy: “Top users by average health score (min. 3 scans).”
- Server ranks usernames with at least 3 scored scans, by average health score descending, then scan count descending. Cap 50.
- Row: rank (gold / silver / bronze emoji for 1–3, otherwise `#n`), `@username`, average score, scan count.
- Empty: “No qualifying users yet. Be the first — set a username and scan some food!”
- Health profile fields are excluded from this response.

### 7.9 Profile

Two sections.

**Display name**

- Username: 3–20 characters, letters, numbers, underscore. Unique, case-insensitive.
- Shown on the leaderboard as `@username`.
- Errors: “Username must be 3–20 chars (letters, numbers, underscore).” / “That username is taken.”

**Health info** (optional, private)

| Field | Rules |
| --- | --- |
| Gender | Prefer not to say, Female, Male, Non-binary, Other. Stored as `""` / `female` / `male` / `non_binary` / `other`. |
| Age | Integer 1–129. |
| Weight | kg, > 0 and < 500. |
| Height | cm, > 0 and < 300. |
| Conditions | Free text, max 500. Example: diabetes, hypertension, PCOS, lactose intolerance. |
| Allergies | Free text, max 500. Example: peanuts, gluten, soy. |

- When weight and height are both set, show BMI = weight / (height in metres)², one decimal.
- Copy: stored privately; never shown on the leaderboard; used to personalise scan advice.
- Save button. Success toast: “Profile saved!”

The server builds a health context for the model from gender, age, weight, height, BMI, conditions, and allergies. `personalAdvice` must mention listed allergens and conflicts with conditions such as diabetes, hypertension, or PCOS when relevant, and may reference BMI or gender. Leave it empty when the profile is empty.

### 7.10 Trust & privacy

Include these statements, in the product’s voice:

- Authentication provider stores passwords hashed. One account per email.
- Only the owner can read or edit their profile, scans, and consumption. Enforced by row-level security.
- Collected: email, optional username, optional health profile, scan history (product names, submitted ingredients, analysis), and items marked consumed.
- Used to personalise insights and weekly intake. Personal data is not sold.
- HTTPS in transit. Users cannot edit plan, scan count, or subscription columns.
- Quota and leaderboard aggregation run on the server.
- Only the session storage required to stay signed in. No third-party ad trackers.
- Subprocessors: hosting and database (Lovable Cloud / Supabase) and an AI gateway that analyses ingredient lists and label photos.
- Users can edit health profile in the app. Account-deletion requests go to the team.
- Closing line: general informational analysis, not a medical service.

### 7.11 Healthy snacks guide

Ship the existing article as an in-app page (or a trusted web view of the same content). Title: “The Perfect Healthy Snack: What to Look for on the Label.” It covers a short label-reading rule, how to read an ingredient list, additives worth a second look, what a good snack looks like, and a prompt to scan with RAPscanz. It does not require sign-in.

---

## 8. Plans and feature matrix

Prices are Indian rupees, monthly, as shown in the product. Payments are not live in the current web app (“Payments will be enabled soon”). The Flutter app must still **display** plans and **enforce** whatever plan the server returns.

| | Free | Pro | Pro+ | Pro Max | Unlimited (role) |
| --- | --- | --- | --- | --- | --- |
| Price | ₹0 | ₹200 / mo | ₹500 / mo | ₹1,200 / mo | Not sold |
| Scan allowance | 30 total | 60 | 120 | 240 | Unlimited (limit sentinel 999,999) |
| Ingredient, photo, and barcode analysis | Yes | Yes | Yes | Yes | Yes |
| Health score, rating, summary, calories | Yes | Yes | Yes | Yes | Yes |
| Advantages, disadvantages, cautions | Yes | Yes | Yes | Yes | Yes |
| Personal advice from health profile | Yes | Yes | Yes | Yes | Yes |
| History, weekly log, leaderboard, feedback | Yes | Yes | Yes | Yes | Yes |
| Estimated % on each caution | | Yes (in the concern text) | Yes (`percentage` field) | Yes | Yes |
| Chemical formula and scientific name | | | Yes | Yes | Yes |
| Safe consumption guide | | | Yes | Yes | Yes |
| Over-consumption risk profile | | | | Yes | Yes |
| Dietary classification | Locked teaser | Locked teaser | Locked teaser | Yes | Yes |
| Body-impact map | Locked teaser | Locked teaser | Locked teaser | Yes | Yes |

**Server behaviour the client must trust**

- Effective plan is `free` when a paid plan’s `plan_expires_at` is in the past.
- Roles `admin`, `founder`, and `collaborator` are unlimited and are treated as Pro Max for feature visibility. The profile API may label them `Unlimited` while the quota function records the plan as `pro_max`. The app should treat either `plan == pro_max` or `isUnlimited` / `plan == unlimited` as Pro Max features unlocked.
- Users cannot update `plan`, `plan_expires_at`, `scan_count`, `is_subscribed`, or `subscription_expires_at`.

**Allowance semantics to implement**

Marketing copy says paid tiers are “per month” and the quota error says “this cycle.” The current database function increments a lifetime `scan_count` and does not reset it on a calendar month. For the mobile app:

- Display the numbers the server returns (`remaining`, `scanLimit`, `planLabel`).
- Treat a monthly reset as a **backend change**, not something the client invents. If product wants a true monthly cycle, reset `scan_count` (or use a period column) on the server when `plan_expires_at` rolls or on each billing anniversary. Do not reset quotas on the phone.

---

## 9. Billing

A `payments` table already exists for Razorpay (INR, amount in paise, order id, payment id, status). `grant_subscription` exists for server-side grants. The web UI does not complete checkout.

For mobile v1:

- Show the four plan cards and the user’s current plan.
- When the user is out of scans, show the same upgrade message as the web app.
- Do not embed a web Razorpay checkout inside the iOS app. Store billing must follow App Store and Play billing rules before any purchase button charges money.
- Until billing is approved, upgrade buttons explain that payments are coming and do not pretend a purchase succeeded.
- After a successful grant, the next `getProfile` reflects the new plan and limit. The app does not write the plan itself.

---

## 10. Analysis pipeline (server contract)

The phone sends a scan request. It does not call the model or the food registries directly, and it does not hold the AI key.

```
Authenticated request
  scanType: "ingredients" | "barcode"
  text?: string            // ingredients paste, max 10_000
  barcode?: string         // 1–32 chars, [A-Za-z0-9-], checksum-valid
  imageDataUrl?: string    // max ~7.5 MB encoded; client rejects > 5 MB files
```

**Pipeline**

1. Validate input.
2. If the client already classified the code as in-store, stop (no request).
3. Consume one quota unit. Abort on `quota_exceeded`.
4. Load the user’s health profile.
5. Photo: OCR candidate digit runs of length 8–14. Ignore dates, prices, batch codes, phone numbers, and weights. Keep the first candidate with a valid check digit, preferring length 13, then 12, then 14, then 8. A valid 12-digit code may be promoted to 13 digits with a leading 0.
6. In-store code from OCR: return `{ localBarcode }` and do not analyse. The credit was already consumed by the current server; mobile should avoid this by detecting prefix `2*` before upload when the scanner reads the code itself.
7. Barcode: read `barcode_cache`. On hit, recompute organ impact from a fresh registry lookup when nutriments exist, save a scan row for this user, and return the cached analysis.
8. On miss: Open Food Facts (`world.openfoodfacts.org` API v2), then UPCitemdb. A 12-digit miss retries with a leading 0. Require a registry hit. If ingredients are missing, the model may analyse nutrition only and must not rewrite name, brand, parent company, or category.
9. Text or unreadable-barcode photo: the model reads the ingredients (and the image, for photos).
10. Model output is JSON matching section 11. Clamp health score 0–100 and calories 0–5000.
11. For registry hits, overwrite identity fields with registry values and replace organ arrays with the rule engine.
12. Insert `scans`. Upsert `barcode_cache` on the barcode (typed or OCR’d) so the next user gets the same result.
13. Return the result plus `scanId`, `remaining`, `scanLimit`, `plan`, `planLabel`.

**Registries**

- Open Food Facts fields used: product name (including English and Hindi ingredient text), brands, brand owner, categories, quantity, nutriments, labels.
- UPCitemdb fields used: title, brand, category. It often has no ingredients; nutrition then relies on the model with identity locked.
- GS1 prefix is passed only as a country-of-issue hint. It is not used to invent a brand. India is prefix 890.

**Model**

- Current web app uses Gemini 2.5 Flash through the Lovable AI gateway, JSON mode.
- The Flutter app is agnostic to the model vendor. It depends on the response schema and the rules in this PRD.
- Tier-specific instructions are applied on the server from the effective plan (percentage and formula fields, consumption tip, risk profile, body map). The client hides locked sections even if a payload contains them, so a downgraded account does not see Pro Max detail from an old cached object that was generated for a higher tier. Prefer having the server omit gated fields for the caller’s plan.

**Category and brand rules the server must keep**

- `productName` is the consumer-facing product (“Dairy Milk Silk”). `brand` is the line (“Dairy Milk”). `parentCompany` is the owner (“Mondelez (formerly Cadbury)”).
- Categories stay specific: milk chocolate bar, cream-filled biscuit, salted potato chips, energy/protein bar, extruded corn snack, peanut-jaggery chikki, toned milk, and so on.
- Do not copy nutrition numbers across categories.

---

## 11. Data contracts

### 11.1 Scan result

```json
{
  "productName": "string",
  "brand": "string?",
  "parentCompany": "string?",
  "category": "string?",
  "rating": "good | okay | caution | avoid",
  "healthScore": 0,
  "caloriesKcal": 0,
  "summary": "string",
  "advantages": ["string"],
  "disadvantages": ["string"],
  "cautions": [
    {
      "ingredient": "string",
      "concern": "string",
      "severity": "low | medium | high",
      "percentage": "string?",
      "chemicalFormula": "string?",
      "scientificName": "string?"
    }
  ],
  "personalAdvice": "string?",
  "consumptionTip": {
    "safeDaily": "string",
    "limit": "string",
    "source": "string"
  },
  "riskProfile": {
    "illnesses": ["string"],
    "addictions": ["string"],
    "chronicDamage": ["string"],
    "temporaryEffects": ["string"],
    "organDamage": ["string"]
  },
  "bodyDamage": [
    { "part": "string", "severity": "low | medium | high", "reason": "string", "trigger": "string?" }
  ],
  "bodyBenefit": [
    { "part": "string", "severity": "low | medium | high", "reason": "string", "trigger": "string?" }
  ],
  "dietaryType": "veg | non-veg | vegan | unknown",
  "dietaryReason": "string?"
}
```

Risk profile is empty for clearly healthy products (health score ≥ 75 or rating `good`). Each risk list is 2–5 short clauses, specific to this product’s ingredients, grounded in published guidance (WHO, FDA, EFSA, ICMR-NIN, AHA, NIH). Consumption-tip numbers must cite a real guideline source. The product must not invent diseases or limits.

### 11.2 Tables to reuse

| Table | Mobile use |
| --- | --- |
| `profiles` | id = auth user id. email, username, gender, age, weight_kg, height_cm, illnesses, allergies, scan_count, plan (`free` \| `pro` \| `pro_plus` \| `pro_max`), plan_expires_at, is_subscribed, subscription_expires_at. |
| `scans` | User’s analyses. `result` jsonb holds the full object. List projection: id, product_name, scan_type, rating, health_score, calories_kcal, summary, created_at. |
| `consumption` | id, user_id, scan_id, product_name, calories_kcal, consumed_at. |
| `scan_feedback` | rating 1–5, buy_again `yes` \| `maybe` \| `no`, comment, unique per (user, scan). |
| `barcode_cache` | Shared by barcode. Clients read through the scan API, not by querying the cache to skip quota. |
| `user_roles` | `admin` \| `founder` \| `collaborator` \| `user`. |
| `payments` | Server-only writes. User may read their own rows later for a receipts screen. |

Row-level security: a user reads and writes only their own profile, scans, consumption, and feedback. Plan and quota columns are not client-writable.

### 11.3 Suggested Flutter modules

```
lib/
  app/                // router, theme, session gate
  features/auth/
  features/home/
  features/scan/      // inputs, result, local inventory
  features/history/
  features/weekly/
  features/leaderboard/
  features/profile/
  features/plans/
  features/content/   // trust, snack guide
  data/               // supabase client, scan api, dto
  domain/             // ScanResult, Plan, rating, organ map
```

Recommended packages (equivalents are fine): `supabase_flutter`, `mobile_scanner` or `mobile_scanner` plus image picker, `flutter_secure_storage`, image compression before upload, a local store for in-store barcodes (`shared_preferences` or hive).

Render the body map as a Flutter `CustomPainter` or an SVG asset with tappable regions. Reuse the organ list in section 7.4.2. A static teaser image is enough for the locked state.

---

## 12. UX and visual design

- **Feel:** clean, health-conscious, high trust. White surfaces, charcoal text, deep green primary, fresh leaf-green accent. Hard offset shadows on marketing cards (a few pixels, primary-coloured), not soft generic SaaS blur.
- **Type:** display face in the spirit of Bricolage Grotesque for headlines and scores; a humanist sans in the spirit of Plus Jakarta Sans for body. On mobile, use bundled OFL fonts with those names, or the closest SIL-licensed equivalents already approved for the app.
- **Logo:** rounded square, green-to-teal gradient, white scanner-reticle corners, a leaf, a horizontal laser sweep. Wordmark: RAP + “scanz” in primary green.
- **Layout:** phone-first, max content width on tablets. Bottom navigation with icons: scan, history, flame (weekly), trophy, person. Safe areas respected. Primary actions full width.
- **Feedback:** short toasts for success and failure. Inline cards for quota and local-barcode warnings.
- **Motion:** a short scan-chamber / laser sweep while analysis runs (the web preview is about 6 seconds; the real wait is network-bound). Do not block the UI thread.
- **Accessibility:** rating is never colour alone (text label plus colour). Severity chips include the word. Body-map organs expose a text list as well as the graphic, so screen-reader users get the same reasons. Dynamic type up to a large size without clipping the score ring. Camera permission denial explains how to enable it and still allows paste and manual barcode entry.
- **Empty, loading, and error** states exist for history, weekly, leaderboard, scan detail, and profile save.

---

## 13. Non-functional requirements

| Area | Requirement |
| --- | --- |
| Platforms | One Flutter app, iOS and Android. Phone layout is primary; tablet uses the same screens with a wider measure. |
| Auth | Session survives restart. Expired refresh tokens return the user to sign-in. |
| Privacy | Health text, label photos, and ingredient pastes are sent only to the RAPscanz backend over TLS. Photos are not saved to the scan row in the current product (only text or barcode is stored in `input_text`). Do not add a photo archive in v1. |
| Performance | History and profile open from cache when offline and refresh when online. A scan always needs the network. Image upload is compressed so a typical label photo stays well under 5 MB. |
| Integrity | Check digits are validated on the device for faster errors and again on the server. |
| Consistency | Barcode cache is the source of a repeated barcode’s verdict. Organ rules override the model when nutriments exist. |
| Safety | Persistent disclaimer on Home and on the first scan result of a session, or in the result footer: informational, not medical advice. |
| Localisation | English UI for v1. Ingredient text may be Hindi or another language; the pipeline already reads Hindi ingredient strings from Open Food Facts. Do not machine-translate the UI in v1. |
| Analytics | No third-party advertising SDKs. Crash reporting is allowed if it does not include ingredient text, photos, or health fields. |
| Testing | See section 14. |

---

## 14. Acceptance criteria

1. A new user can sign up, land on Scan, and see “Free · 30 of 30 scans left” (or remaining after use).
2. Pasting a real ingredient list returns a result with rating, score, summary, calories, advantages, disadvantages, and cautions, and the history list shows it.
3. Entering a known EAN-13 (for example an Indian 890… code present in Open Food Facts) returns the registry product name and brand, not a guessed one. Scanning it again returns the same score and summary.
4. A barcode with a bad check digit never reaches the model and does not decrement quota.
5. An unknown but checksum-valid barcode shows the registry-miss error and does not invent a brand.
6. A code starting with 2 opens local inventory, spends no credit, and is recognised after the app restarts.
7. A label photo under 5 MB either resolves to a barcode result or to an image analysis. A photo over 5 MB is rejected on the device.
8. With weight, height, and an allergy saved, a later scan can show a “For you” note. Those fields do not appear on the leaderboard.
9. “I ate this” increases the weekly total by that scan’s calories. Deleting the entry removes only the log. The same scan can be logged again.
10. A user with fewer than 3 scans or no username is absent from the leaderboard. A qualifying user appears with a rounded average.
11. A free account sees locked teasers for dietary type and the body map, and does not see formulas, the consumption guide, or the risk profile.
12. A Pro Max (or unlimited-role) account sees dietary type with reason, both body silhouettes, and the risk profile when the product is not in the healthy band.
13. Feedback saves stars, buy-again, and comment, and reopening the scan shows the saved values.
14. Sign-out blocks Scan, History, Weekly, and Profile. Leaderboard, Home, Trust, and the guide remain reachable.
15. VoiceOver / TalkBack can read the verdict, score label, and each caution without relying on colour.

---

## 15. Edge cases

- Expired paid plan behaves as Free on the next scan, including locked Pro Max sections.
- Quota is consumed even when the model later fails. The UI shows the error and the reduced remaining count. (Matching the current server order.)
- Cache hit still writes a personal `scans` row so history and the leaderboard include it.
- Image OCR must not treat expiry dates, MRP, or net weight as barcodes.
- `healthScore` and `caloriesKcal` arriving outside range are clamped before display, even if an old row is dirty.
- Username uniqueness is case-insensitive.
- Weekly grouping uses the device’s local calendar day.
- Deleting a consumption row that belongs to another user fails silently from the user’s point of view (RLS).
- No network on Scan: “You need a connection to analyse a product.” Local inventory lookup still works.

---

## 16. Open decisions

These do not block building the scan, history, weekly, profile, and leaderboard flows.

1. **Where payment happens.** App Store / Play billing versus Razorpay on the web account. The data model can store a plan either way; the client must not grant the plan.
2. **Monthly quota reset.** Product copy says per month. The database currently counts lifetime scans. Pick one on the server before advertising a reset date in the app.
3. **Photo OCR and quota.** Today a photo that turns out to be an in-store barcode has already spent a credit. Mobile live-scan can avoid that when the camera reads the bars directly.

---

## 17. Traceability

| Mobile capability | Current web source |
| --- | --- |
| Home, pricing, disclaimer | `src/routes/index.tsx` |
| Auth | `src/routes/auth.tsx` |
| Scan UI, local inventory, gating | `src/routes/_authenticated/scan.tsx` |
| Analysis, quota, registries, schema | `src/lib/scan.functions.ts` |
| Organ rules | `src/lib/organImpact.ts` |
| Body map | `src/components/BodyDamageMap.tsx` |
| Score ring | `src/components/HealthScore.tsx` |
| Feedback | `src/components/ScanFeedback.tsx`, `src/lib/feedback.functions.ts` |
| History | `src/routes/_authenticated/history.tsx`, `history.$id.tsx` |
| Weekly | `src/routes/_authenticated/weekly.tsx` |
| Leaderboard | `src/routes/leaderboard.tsx`, `get_leaderboard()` |
| Profile | `src/routes/_authenticated/profile.tsx` |
| Trust, snack guide | `src/routes/trust.tsx`, `src/routes/guides/healthy-snacks.tsx` |
| Schema and RLS | `supabase/migrations/` |
