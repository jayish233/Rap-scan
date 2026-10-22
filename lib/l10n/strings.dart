/// English UI copy. Strings from design.md §10 are verbatim — never
/// paraphrase them. Supporting copy (navigation labels, page prose) lives here
/// too so every user-facing string has one home.
abstract final class Strings {
  // --- Copy deck (design.md §10) ---
  static const positioningLine = "Know what's actually in your food.";
  static const homeSupportingCopy =
      'Snap a label, paste ingredients, or scan a barcode — get the good, the bad, and the chemicals worth a second look.';
  static const homeCta = 'Start scanning';
  static const disclaimer = 'For information only — not medical advice.';
  static const inProductDisclaimer = 'RAPscanz is informational. It is not medical advice.';
  static String quotaChip(String plan, int remaining, int limit) =>
      '$plan · $remaining of $limit scans left';
  static String quotaChipUnlimited(String plan) => '$plan · Unlimited scans';
  static const scanButton = 'Scan & analyze';
  static const textPlaceholder = 'Paste the ingredient list from the back of the packet…';
  static const emptyTextError = 'Paste the ingredient list first.';
  static const oversizeImage = 'Image must be under 5MB.';
  static const invalidBarcode =
      'Invalid or fake barcode. Real product barcodes are 8, 12, 13, or 14 digits with a valid check digit (EAN/UPC). Please re-enter or rescan.';
  static String registryMiss(String code) =>
      "Product not found in the Open Food Facts / GS1 registry for barcode $code. We don't guess product identity from barcode prefixes — please scan the label photo or paste the ingredients instead.";
  static const scanningBarcode = 'Looking up barcode & consulting AI registry…';
  static const scanningText = 'Analyzing your scan…';
  static const scanningShort = 'Analyzing…';
  static const photoBarcodeToast = 'Photo scanned — barcode detected & analyzed.';
  static const scanCompleteToast = 'Scan complete.';
  static const quotaExhausted =
      "You've used all your scans for this cycle. Upgrade to Pro (₹200/mo · 60), Pro+ (₹500/mo · 120) or Pro Max (₹1200/mo · 240 + 3D body-damage map) to keep scanning.";
  static const rateLimited = 'Too many scans right now. Please try again in a moment.';
  static const aiUnavailable = 'The analysis service is temporarily unavailable. Please try again.';
  static const aiCreditsExhausted = 'AI credits exhausted. Please contact the app owner.';
  static const noNetwork = 'You need a connection to analyse a product.';
  static String localBarcodeFromPhoto(String code) =>
      'Barcode $code read from photo — looks like a local/in-store item.';
  static const localSavedCard = 'Saved on this device.';
  static const ratingGood = 'Good choice';
  static const ratingOkay = 'Okay-ish';
  static const ratingCaution = 'Caution';
  static const ratingAvoid = 'Better avoid';
  static const scoreExcellent = 'Excellent for you';
  static const scoreHealthy = 'Healthy choice';
  static const scoreModeration = 'Okay in moderation';
  static const scoreRarely = 'Eat rarely';
  static const scoreAvoid = 'Better avoid';
  static String caloriesLine(int kcal) => '~$kcal kcal per serving.';
  static const ateThisSuccess = 'Added to this week.';
  static const noneNotable = 'None notable.';
  static const noCautions = 'No flagged chemicals.';
  static const dietaryLockedTitle = 'Veg · Non-Veg · Vegan';
  static const dietaryLockedBody = 'Unlock dietary classification (with the specific ingredient reason).';
  static const bodyMapLocked = 'Upgrade to Pro Max';
  static const bodyMapNoHarm = 'No specific organ harm detected';
  static const bodyMapNoBenefit = 'No specific organ benefit detected';
  static const feedbackPrompt = 'Would you buy this again?';
  static const historyTitle = 'Scan history';
  static const historySubtitle = "Everything you've scanned with RAPscanz.";
  static const historyEmpty = 'No scans yet';
  static const scanNotFound = 'Scan not found';
  static const weeklyTitle = 'This week';
  static const weeklySubtitle = 'Calories from the foods you marked as eaten.';
  static const weeklyEmpty = 'Nothing logged yet this week';
  static const leaderboardCopy = 'Top users by average health score (min. 3 scans).';
  static const leaderboardEmpty =
      'No qualifying users yet. Be the first — set a username and scan some food!';
  static const usernameFormatError = 'Username must be 3–20 chars (letters, numbers, underscore).';
  static const usernameTaken = 'That username is taken.';
  static const profileSaved = 'Profile saved!';
  static const guideTitle = 'The Perfect Healthy Snack: What to Look for on the Label';
  static const billingPlaceholder = 'Payments will be enabled soon';

  // --- Home (PRD §7.2) ---
  static const howItWorksTitle = 'How it works';
  static const howItWorksSteps = [
    'Paste or photograph the ingredient list.',
    'Or scan the barcode and pull the product from the open food database.',
    'Get the verdict: advantages, disadvantages, chemical cautions.',
  ];
  static const pricingTitle = 'Plans';
  static const pricingSubtitle = 'Prices in Indian rupees, billed monthly.';
  static const unlimitedNote =
      'Unlimited scans and every Pro Max feature are reserved for admin, founder and collaborator accounts. Not sold.';
  static const linkLeaderboard = 'Leaderboard';
  static const linkTrust = 'Trust & privacy';
  static const linkGuide = 'Healthy snacks guide';

  // --- Auth (PRD §7.1) ---
  static const signIn = 'Sign in';
  static const createAccount = 'Create account';
  static const email = 'Email';
  static const password = 'Password';
  static const passwordHint = 'At least 6 characters';
  static const emailInvalid = 'Enter a valid email address.';
  static const passwordTooShort = 'Password must be at least 6 characters.';
  static const haveAccount = 'Already have an account? Sign in';
  static const needAccount = 'New to RAPscanz? Create an account';
  static const confirmEmail = 'Check your email to confirm your account, then sign in.';
  static const genericError = 'Something went wrong. Please try again.';

  // --- Navigation ---
  static const navScan = 'Scan';
  static const navHistory = 'History';
  static const navWeekly = 'Weekly';
  static const navLeaderboard = 'Leaderboard';
  static const navProfile = 'Profile';
  static const signOut = 'Sign out';
  static const backHome = 'Back to home';
  static const retry = 'Retry';
  static const quotaUnavailable = 'Scans left unavailable';

  // --- Configuration ---
  static const configMissingTitle = 'Backend not configured';
  static const configMissingBody =
      'Run the app with --dart-define=SUPABASE_URL=… and --dart-define=SUPABASE_ANON_KEY=… '
      '(or --dart-define-from-file=config/local.json).';
}
