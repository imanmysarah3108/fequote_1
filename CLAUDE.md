# CLAUDE.md — QuoteMyMood UI/UX redesign

## What this project is
QuoteMyMood: a Flutter mobile app that detects emotion via Facial Expression
Recognition (FER) + Content-Based Filtering (CBF) and recommends motivational
quotes. Stack: Flutter (frontend) + FastAPI + Firebase + Google Cloud Run.
Flutter app lives at `mobile_app/flutter_app/`. ~7 screens.

## Current task
A **pure UI/UX redesign pass** to raise the System Usability Scale (SUS) score
and address validated user feedback — WITHOUT changing any feature, logic,
model behaviour, API call, data flow, or navigation.

Baseline SUS from the evaluation survey (N=52): **mean 74.9, median 72.5**
("Good" / grade C→B / "Acceptable"). The survey's "most useful feature" column
is dominated by FER emotion detection, quote recommendations, and
"User-Friendly Interface" — so protect what works and make the FER result feel
trustworthy.

## HARD CONSTRAINTS — do not violate
- No feature added/removed. Same screens, same capabilities.
- No change to app logic, state management, control flow (FER/CBF/NRC/SBERT/
  Gemini pipeline, recommendation logic, auth).
- No change to API endpoints, request/response handling, Firebase calls, data models.
- No change to navigation structure (same routes, order, entry/exit points).
- Do not rename/move/delete functions, variables, providers, or files unless it
  is a purely widget-level visual refactor with identical behaviour.
- No new dependencies without flagging first.
- Every button/input/toggle/gesture keeps the exact same action and result.

**Only allowed to change:** layout, spacing, alignment, typography, colour,
contrast, iconography, component styling, visual hierarchy, empty/loading/error/
success states, labels & microcopy (wording only), animations/transitions, and
accessibility affordances.

After every screen edit, confirm: "Behaviour unchanged — only visuals/layout modified."

## Validated feedback (the only in-scope signal)
1. **Readability / contrast** — repeated: "hard to read the white font",
   "add contrast for readability", "easy to see". HIGHEST priority.
2. **Navigation discoverability** — "some features are difficult to find",
   "simpler layout".
3. **Simpler / more intuitive layout** — "minimalist interface", "more intuitive".

Out of scope (do NOT implement): journal, dark mode, custom themes, Malay/
faith/more quotes, AI image gen, music, social export, mood timeline charts,
reminder-copy changes, backend speed, marketing/privacy. These are new
features/logic/content, not restyling.

## Design tokens (source of truth)
`lib/constants/app_theme.dart` is the single source of truth for colour,
typography, spacing, radii, elevation. All existing token NAMES are preserved
for backward compatibility; new tokens are additive:
- Readability fix: body text weight w300→w400, opacity↑, `bodySize` 14→15,
  `onGradientTextShadow` for legibility over the light-peach gradient end.
- `emotionColors` map + `emotionColor()` helper — standardises how the
  ALREADY-detected emotion is coloured (display only; never touches FER/CBF/NRC).
- Semantic `success/error/warning/info`; `cardShadow`; `space4`; `captionSize`/
  `bodySmall`; `minTapTarget = 48`; themed `SnackBar`.

IMPORTANT: `app_theme.dart` and the redesigned screens are a MATCHED PAIR.
Screens call `AppTheme.emotionColor`, `cardShadow`, `minTapTarget` etc. — apply
the theme together with the screens or it won't compile.

## SUS heuristics → concrete moves
1. Easy/not complex → declutter, one primary action per screen, whitespace.
2. Consistent → one design language: buttons, cards, spacing scale, radii,
   colour tokens, icon style, type across all screens.
3. Learn quickly/confident → clear labels, predictable primary-action placement,
   obvious tappable affordances.
4. No support needed → descriptive headings, meaningful empty states, inline guidance.
5. Not cumbersome → min taps/scroll, smooth transitions, pressed/loading feedback.
6. FER confidence → make detected emotion + its basis clearly visible (display only).

## Progress
- [x] `lib/constants/app_theme.dart` — upgraded, backward-compatible.
- [x] `lib/screens/result_screen.dart` — FER-basis eyebrow, emotion-coloured
      bubble, legible body text, ≥48px "Scan Again", Semantics label.
- [~] `lib/screens/reflect_screen.dart` — draft exists; verify loading/guidance states.
- [ ] Bottom nav unification: `lib/screens/main_navigation.dart` (icon-only,
      white60 unselected) vs `lib/widgets/app_bottom_nav_bar.dart` (has labels) —
      unify: labels under icons, raise unselected contrast, ≥48px targets.
      Keep same routes / `setIndex` calls.
- [ ] `lib/screens/quote_screen.dart` — consistent cards, style placeholder as empty state.
- [ ] `lib/views/ai_rewrite_screen.dart` — loading/result/empty states, label icon-buttons.
- [ ] `lib/views/mood_dashboard_screen.dart` — uniform card/shadow tokens, keep empty state.
- [ ] `lib/screens/settings_screen.dart` — consistent glass cards, readable secondary text.
- [ ] `lib/screens/welcome_screen.dart` — single clear primary CTA.

## Verify after each change
`flutter analyze` must pass. Confirm: navigation routes/order unchanged; every
button same action; no new dependency; contrast + tap targets meet minimums;
detected emotion / FER basis clearly presented.