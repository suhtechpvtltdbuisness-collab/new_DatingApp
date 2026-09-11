#!/usr/bin/env bash
set -euo pipefail
flutter clean
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build appbundle --release
flutter build apk --release
printf '\nRelease artifacts:\n  build/app/outputs/bundle/release/app-release.aab\n  build/app/outputs/flutter-apk/app-release.apk\n'
