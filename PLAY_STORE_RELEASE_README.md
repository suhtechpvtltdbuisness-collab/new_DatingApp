# Google Play Production Release

## Production identity
- Android applicationId / namespace: `com.suhtech.datingapp`
- App name: `DatingApp`
- Version: `1.0.0+1`
- Release builds use a dedicated upload keystore through `android/key.properties`.

## Release fixes applied
- Removed `com.example` Android identity.
- Removed debug-key signing from release builds.
- Added INTERNET permission to the production manifest.
- Retained coarse/fine location permissions required for nearby discovery.
- Disabled cleartext HTTP traffic.
- Disabled Android backup for locally stored auth data.
- Enabled release minification/resource shrinking.
- Added ProGuard configuration.

## Build commands
From the project root:

    flutter clean
    flutter pub get
    flutter analyze
    flutter test
    flutter build appbundle --release
    flutter build apk --release

Expected artifacts:
- `build/app/outputs/bundle/release/app-release.aab` (Google Play upload)
- `build/app/outputs/flutter-apk/app-release.apk` (device/manual testing)

## Google Play console items that cannot be embedded in the binary
Before production publishing, complete the Data safety form, Content rating, 18+ target audience configuration, Child Safety Standards self-certification for a dating/social app, privacy-policy URL, and app access/test credentials if login is required.

## UI/UX redesign (this pass)
The app's whole visual language was overhauled to a bold gradient /
glassmorphism design system — see `lib/utils/theme.dart` for the single
source of truth (colors, gradients, glass-surface tokens) and
`lib/widgets/common/` for the shared `GlassCard`, `GradientButton` and
`GradientScaffold` widgets it's built from. Onboarding, sign-in, home
navigation, the swipe deck, match celebration, profile detail, liked-you,
chat list and matches screens were rebuilt on this system; every other
screen had its color palette unified onto the same tokens so the whole
app now reads as one consistent product instead of several different
color schemes stitched together. Also fixed while in there: the People
tab in Home was wired to the real (API-backed) swipe deck instead of a
static demo card, tapping a swipe card now opens a live profile detail
view, the dead-code Matches screen was restyled and linked from Chats →
"See all", and the API client now actually refreshes an expired access
token instead of leaving a `// TODO` in the 401 handler.

## Why there's no compiled .aab/.apk in this delivery
This build environment's outbound network is restricted to a small
allowlist that does **not** include the Flutter SDK, Android SDK, or
Gradle/Maven download hosts (`dl.google.com`, `storage.googleapis.com`,
`services.gradle.org`, npm/PyPI registries, etc. all refuse the
connection) — the same limitation `RELEASE_VALIDATION.txt` already
called out before this pass. So the compile step has to happen
somewhere with normal internet access:

- **Easiest: GitHub Actions.** `.github/workflows/build-release.yml` is
  already set up — push this repo to GitHub, add the signing secrets it
  documents at the top of that file, and every push to `main` (or a
  manual "Run workflow" click) produces a signed `app-release.aab` and
  `app-release.apk` as downloadable build artifacts.
- **Or locally / any CI**: the `Build commands` above work unchanged on
  any machine with the Flutter SDK installed.

## ⚠️ Keystore password — please rotate before your first Play upload
`android/key.properties` (and the keystore's own passwords) ship in
plaintext in this source tree so a local build works out of the box.
That's fine for development, but since these credentials have now
passed through several hands (including this AI session), **generate a
fresh upload keystore before you first publish to Play Console**, if you
haven't already uploaded a release signed with this one:

    keytool -genkey -v -keystore android/keystore/datingapp-upload.jks \
      -keyalg RSA -keysize 2048 -validity 10000 -alias upload

then update `android/key.properties` to match and store the new
passwords in a password manager (and as the GitHub Actions secrets
above) — never back in the repo. If you've *already* uploaded a release
to Play Console signed with the current keystore, keep using it instead
(Play ties future updates to the signing key) and just make sure
`key.properties`/`*.jks` stay out of version control (`android/.gitignore`
already excludes both).

## Admin panel
A separate, self-contained admin web app (login + user management +
moderation queue + match overview) lives in `../admin_panel/` alongside
this Flutter project — see its own `README.md` for setup. It ships with
its own SQLite database and demo data so it's explorable immediately;
wiring it to your production backend is documented there too.
