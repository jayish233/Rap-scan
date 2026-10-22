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
  static const welcomeBack = 'Welcome back';
  static const signInSubtitle = 'Sign in to keep scanning.';
  static const createAccountSubtitle = '30 free scans, no card needed.';
  static const newToRapscanz = 'New to RAPscanz? ';
  static const createAnAccount = 'Create an account';

  // --- Scan result (PRD §7.4 section names) ---
  static const summaryTitle = 'Summary';
  static const forYouTitle = 'For you';
  static const caloriesTitle = 'Calories';
  static const ateThis = 'I ate this';
  static const advantagesTitle = 'Advantages';
  static const disadvantagesTitle = 'Disadvantages';
  static const cautionsTitle = 'Chemical & ingredient cautions';
  static const formulaLabel = 'Formula';
  static const scientificNameLabel = 'Scientific name';
  static String byParent(String company) => 'by $company';

  // --- Gated result sections (PRD §7.4.6, 8, 10, 11) ---
  static const dietaryTitle = 'Dietary classification';
  static const consumptionTitle = 'Safe consumption guide';
  static const safeDailyLabel = 'Safe per day';
  static const upperLimitLabel = 'Upper limit';
  static const sourceLabel = 'Source';
  static const riskTitle = 'What over-consumption can cause';
  static const riskIllnesses = 'Illnesses & conditions';
  static const riskAddictions = 'Addiction patterns';
  static const riskChronic = 'Chronic damage';
  static const riskTemporary = 'Temporary effects';
  static const riskOrgan = 'Organ-specific damage';
  static const bodyMapTitle = 'Body-impact map';
  static const bodyMapHarms = 'Harms';
  static const bodyMapBenefits = 'Benefits';
  static const bodyMapTapHint = 'Tap a highlighted organ for the reason.';
  static const bodyMapListTitle = 'Organ details';
  static String triggerLine(String trigger) => 'Trigger: $trigger';
  static const proMaxFeature = 'Pro Max feature';
  static const openBodyMap = 'Open body map';
  static const bodyMapCardSubtitle = 'See which organs this product affects when eaten often.';
  static String scannedBy(String type) => 'scanned by $type';
  static const identifiedViaRegistry = 'Identified via AI Registry Lookup';

  // --- Plans sheet (PRD §9, design.md §4.10) ---
  static const plansTitle = 'Plans';
  static const seePlans = 'See plans';
  static String currentPlanLine(String label) => 'Your plan: $label';
  static const currentPlanBadge = 'Current';
  static String upgradeTo(String plan) => 'Upgrade to $plan';
  static const unlimitedPlanNote = 'Your account has unlimited scans and every Pro Max feature.';

  // --- Scan input ---
  static const modeText = 'Text';
  static const modeBarcode = 'Barcode';
  static const barcodeLabel = 'Barcode number';
  static const barcodeHint = '8, 12, 13 or 14 digits';
  static const scanSubtitle = "Find out what's actually in that packet.";
  static const orTypeNumber = 'Or type the number';
  static const barcodeHintExample = 'e.g. 8901058851234';
  static const barcodeHelper =
      'EAN-8, UPC-A, EAN-13 or ITF-14. In-store labels (prefix 20–29) are saved on your device and use no scan credit.';
  static const scannerViewfinderHint = 'Align the barcode inside the frame';
  static const toggleFlashlight = 'Toggle flashlight';
  static const photoDropHint = 'Tap to take a photo or upload the food label';
  static const quotaExhaustedTitle = "You've used all your scans";
  static const inStoreTitle = 'In-store item';
  static String inStoreBody(String code) =>
      'Barcode $code is a local/in-store code. It is not in global product databases and was not sent for analysis.';
  static const startOver = 'New scan';
  static const modePhoto = 'Photo';
  static const takePhoto = 'Take photo';
  static const chooseFromLibrary = 'Choose from library';
  static const removePhoto = 'Remove photo';
  static const photoHint = 'Photograph the ingredient list or the barcode on the pack.';
  static const scanWithCamera = 'Scan with camera';
  static const scannerTitle = 'Point at the barcode';
  static const scannerHint = 'EAN-8, EAN-13, UPC-A or ITF-14';
  static const close = 'Close';
  static const cameraDeniedTitle = 'Camera access is off';
  static const cameraDeniedBody =
      'To scan with the camera, open Settings › RAPscanz and turn on Camera (and Photos to pick from your library). '
      'You can still paste the ingredients or type the barcode number.';
  static const cameraDeniedToast = 'Camera access is off. You can still paste ingredients or type the barcode.';

  // --- Local / in-store inventory (PRD §7.5) ---
  static const localAddTitle = 'Save in-store item';
  static const localAddButton = 'Add to this device';
  static const localNameLabel = 'Item name';
  static const localNameRequired = 'Enter the item name.';
  static const localPriceLabel = 'Price (optional)';
  static const localWeightLabel = 'Weight / size (optional)';
  static const localRemove = 'Remove from this device';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static String barcodeLine(String code) => 'Barcode $code';

  // --- History ---
  static const scanTypeIngredients = 'Ingredients';
  static const scanTypeBarcode = 'Barcode';
  static const offlineBanner = "You're offline — showing saved data.";
  static const backToHistory = 'Back to history';
  static const scanResultTitle = 'Scan result';
  static const loadFailed = "Couldn't load this right now.";

  // --- Weekly (PRD §7.7) ---
  static const weeklyTotal = '7-day total';
  static const weeklyAverage = 'Average per day';
  static String kcal(int n) => '$n kcal';
  static String kcalUnit(int n) => '$n';
  static String avgPerDay(int n) => 'avg $n kcal/day';
  static const deleteEntry = 'Delete entry';
  static const entryRemoved = 'Removed';
  static const scanSomething = 'Scan something';
  static const runFirstScan = 'Run your first scan';
  static const entriesTitle = 'Entries';
  static const ateThisFailed = "Couldn't add this to your week. Please try again.";

  // --- Leaderboard ---
  static String scanCount(int n) => n == 1 ? '1 scan' : '$n scans';
  static String averageScore(int n) => 'avg $n';

  // --- Profile (PRD §7.9) ---
  static const displayNameTitle = 'Display name';
  static const usernameLabel = 'Username';
  static const usernameHelp = 'Shown on the leaderboard as @username.';
  static const healthInfoTitle = 'Health info';
  static const healthInfoOptional = 'Optional and private.';
  static const genderLabel = 'Gender';
  static const ageLabel = 'Age';
  static const weightLabel = 'Weight (kg)';
  static const heightLabel = 'Height (cm)';
  static const conditionsLabel = 'Conditions';
  static const conditionsHint = 'e.g. diabetes, hypertension, PCOS, lactose intolerance';
  static const allergiesLabel = 'Allergies';
  static const allergiesHint = 'e.g. peanuts, gluten, soy';
  static String bmiLine(String bmi) => 'BMI $bmi';
  static const healthPrivacy =
      'Stored privately. Never shown on the leaderboard. Used to personalise your scan advice.';
  static const saveProfile = 'Save profile';
  static const planTitle = 'Your plan';
  static const usernameHelpShort = '3–20 characters. Shown on the public leaderboard.';
  static const healthInfoHelp =
      'Optional, but it helps tailor the advice on each scan. Stored privately and never shown on the leaderboard.';
  static const upgrade = 'Upgrade';
  static const planPriceLine = 'Pro ₹200 · Pro+ ₹500 · Pro Max ₹1,200 a month. Payments coming soon.';
  static String planName(String label) => '$label plan';
  static String scansLeftOf(int remaining, int limit) => '$remaining of $limit scans left';
  static const unlimitedScans = 'Unlimited scans';
  static const ageError = 'Age must be a whole number from 1 to 129.';
  static const weightError = 'Weight must be more than 0 and less than 500 kg.';
  static const heightError = 'Height must be more than 0 and less than 300 cm.';
  static const freeTextTooLong = 'Keep this under 500 characters.';
  static const profileSaveFailed = "Couldn't save your profile. Please try again.";

  // --- Feedback (PRD §7.4.12) ---
  static const feedbackTitle = 'Rate this product';
  static const feedbackCommentLabel = 'Comment (optional)';
  static const feedbackSubmit = 'Submit';
  static const feedbackThanks = 'Thanks for your feedback!';
  static const feedbackEdit = 'Edit';
  static const feedbackNeedsAnswers = 'Pick a star rating and whether you would buy it again.';
  static const feedbackFailed = "Couldn't save your feedback. Please try again.";
  static String starsLabel(int n) => n == 1 ? '1 star' : '$n stars';
  static const rateThisScan = 'Rate this scan';
  static const addNoteOptional = 'Add a note (optional)';
  static const sendFeedback = 'Send feedback';
  static const feedbackNoteHint = 'Tasted great, but too salty for daily…';

  // --- Navigation ---
  static const navScan = 'Scan';
  static const navHistory = 'History';
  static const navWeekly = 'Weekly';
  static const navLeaderboard = 'Leaderboard';
  static const navRanks = 'Ranks'; // tab label (handoff mockups)
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
