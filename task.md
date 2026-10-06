# Member 3: Private Education Subsystem, task list

Working phase by phase. Branch: `feature/member3-private-education`.
Legend: `[ ]` todo, `[/]` in progress, `[x]` done.

## Phase 0: Prep  (done, committed)
- [x] Fix `test/widget_test.dart` (compiles and passes)
- [x] Add approved dependencies (`crypto`, `intl`, `flutter_localizations`, `integration_test`)
- [x] Bundle fonts (Outfit, Noto Sans Sinhala) in `assets/google_fonts/`, disable runtime fetching
- [x] Folder structure (`widgets/`, `content/`, `l10n/`), `routes.dart`, stub screens (onboarding, PIN setup, pharmacy)
- [x] Update `README.md`
- [x] Verify: `flutter test` passes; `flutter analyze` clean for new code (12 existing issues in other members' files left alone)

## Phase 1: Foundations  (done, committed)
- [x] Extend `AppTheme` tokens (maroon, primaryDark, success)
- [x] Shared widgets (PillButton, AppChip, AppTopBar, HideButton, TopicTile, ArticleRow, AppToast, AppProgressBar, PinDots, Keypad)
- [x] Storage additions (`SavedArticle`, settings box) and l10n skeleton
- [x] Content types, `ContentRepository`, seed content, validation test

## Phase 2: Privacy Lock + auth guard (done, committed)
- [x] `PinService` mock (PBKDF2) with `DEMO_PIN` seed
- [x] `SessionState` and lockout logic
- [x] `PrivacyLockScreen`

## Phase 3: Education Hub (done, committed)
- [x] Hub screen, search, Daily Health Tip, Explore Topics, Learn tab

## Phase 4: Category, Article, Save, Toast, HIDE (done)
- [x] `CategoryScreen` data-driven filter chips and article list
- [x] `ArticleScreen` pink hero illustration, two-toned title, rich blocks, village tip
- [x] Reversible offline save toggle and `AppToast` feedback
- [x] Panic `HideButton` clears navigation stack to `MainScreen` and locks session
- [x] Phase 4 acceptance flow test (Hub -> Category -> Article -> Save in 3 taps <= 4 taps)

## Phase 5: Offline Library  (next)
- [ ] `OfflineLibraryScreen`

## Phase 6: Myth Buster
- [ ] `MythBusterScreen` and quiz logic

## Phase 7: Offline hardening, i18n, accessibility
## Phase 8: Test instrumentation
