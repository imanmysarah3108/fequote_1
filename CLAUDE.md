# CLAUDE.md — QuoteMyMood UI/UX redesign

## What this project is
QuoteMyMood: a Flutter mobile app that detects emotion via Facial Expression
Recognition (FER) + Content-Based Filtering (CBF) and recommends motivational
quotes. Stack: Flutter (frontend) + FastAPI + Firebase + Google Cloud Run.
The Flutter app lives at `mobile_app/flutter_app/`. ~7 screens.

## Current task
A **pure UI/UX redesign pass** to raise the System Usability Scale (SUS) score
and address validated user feedback — WITHOUT changing any feature, logic,
model behaviour, API call, data flow, or navigation.

Baseline SUS from the evaluation survey (N=52): **mean 74.9, median 72.5**
("Good" / grade C→B / "Acceptable"). The survey's "most useful feature" column
is dominated by FER emotion detection, quote recommendations, and
"User-Friendly Interface" — protect what works; make the FER result trustworthy.

## HARD CONSTRAINTS — do not violate
- No feature added/removed. Same screens, same capabilities.
- No change to app logic, state management, control flow (FER/CBF/NRC/SBERT/
  Gemini pipeline, recommendation logic, auth).
- No change to API endpoints, request/response handling, Firebase calls, models.
- No change to navigation structure (same routes, order, entry/exit points — see
  the navigation graph below and keep it identical).
- Do not rename/move/delete functions, variables, providers, or files unless it
  is a purely widget-level visual refactor with identical behaviour.
- No new dependencies without flagging first.
- Every button/input/toggle/gesture keeps the exact same action and result.

**Only allowed to change:** layout, spacing, alignment, typography, colour,
contrast, iconography, component styling, visual hierarchy, empty/loading/error/
success states, labels & microcopy (wording only), animations/transitions, and
accessibility affordances.

After every screen edit, confirm: "Behaviour unchanged — only visuals/layout modified."

## Repo layout (Flutter app: `mobile_app/flutter_app/lib/`)
- `main.dart` — app entry, MultiProvider, routes.
- `app_routes.dart` — `moodDashboard`, `aiRewrite`.
- `constants/app_theme.dart` — DESIGN TOKENS (source of truth).
- `screens/` — welcome (104), reflect/camera (267), result (163), quote (360),
  settings (277), main_navigation (91).
- `views/` — mood_dashboard_screen (225), ai_rewrite_screen (483).
- `widgets/` — app_bottom_nav_bar (180), gradient_button (72), mood_bubble (232),
  glass_container (56), custom_bottom_nav (empty).
- `providers/` — navigation, quote, settings, reflect (ChangeNotifier).
- `viewmodels/` — mood_dashboard, quote_rewrite. `services/` — api, quote_rewrite,
  mood_dashboard, emotion_history, notification, local_notification,
  mood_analytics_local. `models/` — mood_dashboard, emotion_record, quote_rewrite.

## Navigation graph (MUST stay identical)
- Entry: `main.dart` `home: WelcomeScreen`. Named routes: `AppRoutes.moodDashboard`
  → `MoodDashboardScreen`; `AppRoutes.aiRewrite` → `AIRewriteScreen` (takes a
  `String quote` argument via `onGenerateRoute`).
- WelcomeScreen → `pushReplacement` → ReflectScreen.
- MainNavigation holds `screens = [ReflectScreen(0), QuoteScreen(1),
  SettingsScreen(2)]`, switched by `NavigationProvider.setIndex`. Bottom-nav
  items map: camera→0, quote→1, settings→2.
- ReflectScreen → `push` ResultScreen (after capture); `pushNamed` moodDashboard;
  `push` SettingsScreen.
- ResultScreen → "Find My Quote": `setIndex(1)` + `pushReplacement` QuoteScreen;
  "Scan Again": `pop`.
- QuoteScreen → `pushNamed` moodDashboard; `pushReplacement` ReflectScreen;
  `push` SettingsScreen; `pushNamed` aiRewrite (passes selected quote).
- SettingsScreen → `pushNamed` moodDashboard; `pushReplacement` ReflectScreen.
- MoodDashboard → `push` ReflectScreen; `push` SettingsScreen.
- AIRewrite → `pop` (back and "Change").

## Data contract (don't invent data)
- `QuoteProvider` exposes ONLY: `emotion` (String, default `'Peaceful'`),
  `quotes` (List<String>), `selectedQuoteIndex`, `selectedQuote`. Mutators:
  `setResult({emotion, quotes})`, `setSelectedQuoteIndex`, `clear`.
  → There is NO confidence score or NRC-category field. Do NOT add a "confidence
  %%" or per-emotion breakdown to the UI — surface only the *basis* ("detected
  from your expression") using existing data.
- MoodDashboard summary categories: `'Positive'`, `'Needs Support'`,
  `'Emotionally Strained'`.
- FER emotion label is passed lowercased into the emotion bubble.

## Validated feedback (the only in-scope signal)
1. **Readability / contrast** — repeated: "hard to read the white font",
   "add contrast for readability", "easy to see". HIGHEST priority.
2. **Navigation discoverability** — "some features are difficult to find",
   "simpler layout".
3. **Simpler / more intuitive layout** — "minimalist interface", "more intuitive".

Out of scope (do NOT implement): journal, dark mode, custom themes, Malay/faith/
more quotes, AI image gen, music, social export, mood-timeline charts,
reminder-copy changes, backend speed, marketing/privacy. New features/logic/
content, not restyling.

## Design tokens (`lib/constants/app_theme.dart`)
Single source of truth for colour, type, spacing, radii, elevation. All existing
token NAMES preserved for backward compatibility; new tokens are additive:
- Readability: body weight w300→w400, opacity↑, `bodySize` 14→15,
  `onGradientTextShadow` for legibility over the light-peach gradient end.
- `emotionColors` map + `emotionColor()` — standardises how the ALREADY-detected
  emotion is coloured (display only; never touches FER/CBF/NRC).
- Semantic `success/error/warning/info`; `cardShadow`; `space4`; `captionSize`/
  `bodySmall`; `minTapTarget = 48`; themed `SnackBar`.

NOTE: `emotionColors` currently keys on happy/joy, sad/sadness, angry/anger,
fear, surprise, disgust, neutral. The provider default `'Peaceful'` is NOT in
the map (falls back to primaryPurple). Verify the FER model's actual label
vocabulary and extend the map to cover every label it can emit (display-only,
safe). Do not change the labels themselves.

IMPORTANT: `app_theme.dart` and the redesigned screens are a MATCHED PAIR.
Screens call `AppTheme.emotionColor`, `cardShadow`, `minTapTarget`, etc. — apply
the theme together with the screens or it won't compile.

## Recurring anti-patterns to fix (safe, visual-only)
- Per-screen `FontWeight.w300` / low-opacity white overrides that fight the theme
  → remove them and inherit the legible theme styles (this IS the readability fix).
- Ad-hoc paddings → use the spacing scale (`space4/Xs/Sm/Md/Lg/Xl` = 4/8/12/16/24/32).
- Raw `BoxShadow(...)` on cards → use `AppTheme.cardShadow`.
- Icon-only controls where meaning is ambiguous → pair with a label.
- Sub-48px tap targets → wrap in a ≥`minTapTarget` hit area; add `Semantics` labels.

## Two bottom navs — unify styling, keep behaviour
- `screens/main_navigation.dart`: inline nav, ICON-ONLY, `white60` unselected,
  no labels.
- `widgets/app_bottom_nav_bar.dart`: HAS labels ('Dashboard'/'Settings') + camera FAB.
Unify look (labels under icons, raise unselected contrast, ≥48px targets) without
changing routes or `setIndex`/Navigator calls.

## SUS heuristics → concrete moves
1. Easy/not complex → declutter, one primary action per screen, whitespace.
2. Consistent → one design language across all screens (buttons, cards, spacing,
   radii, colour tokens, icons, type).
3. Learn quickly/confident → clear labels, predictable primary-action placement,
   obvious tappable affordances.
4. No support needed → descriptive headings, meaningful empty states, inline guidance.
5. Not cumbersome → min taps/scroll, smooth transitions, pressed/loading feedback.
6. FER confidence → make detected emotion + its basis clearly visible (display only).

## Progress
- [x] `constants/app_theme.dart` — upgraded, backward-compatible.
- [x] `screens/result_screen.dart` — FER-basis eyebrow, emotion-coloured bubble,
      legible body text, ≥48px "Scan Again", Semantics label.
- [~] `screens/reflect_screen.dart` — draft exists; verify loading/guidance states.
- [ ] Bottom-nav unification (see above).
- [ ] `screens/quote_screen.dart` — consistent cards, style placeholder as empty state.
- [ ] `views/ai_rewrite_screen.dart` — loading/result/empty states, label icon-buttons.
- [ ] `views/mood_dashboard_screen.dart` — uniform card/shadow tokens, keep empty state.
- [ ] `screens/settings_screen.dart` — consistent glass cards, readable secondary text.
- [ ] `screens/welcome_screen.dart` — single clear primary CTA.

## Gotchas
- Some files use mixed CRLF/CR line endings (e.g. `app_theme.dart`). Keep edits
  consistent; watch for stray characters when doing find/replace.
- The committed repo (`User Interface Update 3`) is at the ORIGINAL state — commit
  the upgraded `app_theme.dart` + `result_screen.dart` together first, or the
  `emotionColor` reference won't resolve.
- `widgets/custom_bottom_nav.dart` is empty — ignore/don't wire it in.

## Commands (run from `mobile_app/flutter_app/`)
- `flutter pub get` — install deps.
- `flutter analyze` — MUST pass after each change (static analysis + lints).
- `flutter run` — launch on a device/emulator to eyeball the redesign.

## Verify after each change
`flutter analyze` clean; navigation routes/order unchanged; every button same
action; no new dependency; contrast + tap targets meet minimums; detected
emotion / FER basis clearly presented.