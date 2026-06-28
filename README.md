# ZTime Widget

Custom clock widget for Android with glassmorphism design, native TextClock overlay, and Russian localization.

## Features

- Home screen widget with adaptive glass background
- In-app clock face with Apple-style typography
- Native Android `TextClock` for zero-battery time display
- Calendar strip with tap-to-open system calendar
- Adaptive layout for phone / tablet / TV
- Adaptive glass rendering based on device launcher (MIUI, One UI, Stock)
- Bilingual: Russian / English (auto-detect system locale)

## Tech Stack

- Flutter (Dart) — no build step, ES5 compatible
- `home_widget` — widget PNG rendering via `RemoteViews`
- `responsive_framework` — breakpoints (MOBILE / TABLET / DESKTOP)
- `flutter_screenutil` — proportional scaling (`.w`, `.h`, `.sp`, `.r`)
- `device_info_plus` — launcher transparency detection
- `riverpod` — state management
- `slang` — type-safe localization

## Getting Started

```bash
# Install dependencies
flutter pub get

# Code generation (riverpod + slang)
make gen

# Run checks (format + analyze + lint + test)
make check-all

# Build release APKs (split per ABI)
make build-split
```

## Commit Convention

This project uses **bracket-prefix** conventional commits:

| Prefix                        | Bump  | Changelog Section   |
| ----------------------------- | ----- | ------------------- |
| `[FEATURE]` / `[ADD]`         | minor | Features            |
| `[FIX]` / `[BUGFIX]`          | patch | Bug Fixes           |
| `[REFACTOR]`                  | patch | Refactor            |
| `[DOCS]`                      | —     | Documentation       |
| `[PERF]`                      | patch | Performance         |
| `[CI]` / `[LINT]` / `[CHORE]` | —     | Miscellaneous Tasks |
| `[BREAKING]`                  | major | (breaking change)   |

Examples:

```
[FEATURE] add adaptive glass with launcher detection
[FIX] fix clock re-rendering on date change
[REFACTOR] use centralized constants
[BREAKING] remove legacy widget format
```

## Version Management

```bash
# Generate CHANGELOG.md from git history
make changelog

# Bump version (auto-detect from commits) + update pubspec.yaml
make bump

# Full release: check + changelog + bump + tag
make release
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # PrefKeys, AppFormats, AppDurations, etc.
│   ├── device/          # LauncherCapabilities (transparency detection)
│   ├── theme/           # AppColors, AppTheme
│   └── widget/          # WidgetLayout, ClockFace, AdaptiveGlass
├── features/
│   └── clock/
│       ├── controllers/ # ClockSeconds, ClockMinutes
│       └── pages/       # ClockPage, SettingsPage
├── i18n/                # Slang translations (en, ru)
└── main.dart            # Entry point + widget PNG renderer
```

## License

MIT — see [LICENSE](LICENSE).
