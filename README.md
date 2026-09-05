# JobologyX (Flutter)

A cross-platform job board client built with Flutter, Riverpod, and GoRouter for the [JobologyX](https://jobologyx-nodejs-test.onrender.com) backend — a job-seeker/recruiter/admin platform with three distinct roles.

Live backend: `https://jobologyx-nodejs-test.onrender.com/api/v1` (Node.js/Express/MongoDB, deployed separately).

## Tech stack

- **State management:** [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) — `Notifier`/`NotifierProvider` for paginated list state, `FutureProvider.autoDispose` for one-shot fetches.
- **Navigation:** [go_router](https://pub.dev/packages/go_router), with an auth-aware `redirect` that routes to the correct role dashboard (job seeker / recruiter / admin) or the login screen.
- **Networking:** [dio](https://pub.dev/packages/dio), with a shared interceptor for bearer-token auth and session-expiry handling.
- **Local storage:** `flutter_secure_storage` for the auth token, `hive` for light local caching.
- **Models:** `json_serializable` where the response shape is fixed; hand-written `fromJson` where a field is polymorphic or populate-depth varies by endpoint (see `lib/features/applications/models`, `lib/features/admin/models`).

## Project structure

Feature-based, per feature: `data/` (raw Dio calls) → `repositories/` (maps `DioException` to typed `ApiException`) → `providers/` (Riverpod state) → `presentation/{screens,widgets}/`.

```
lib/
  core/            # constants, network client, router, theme, shared widgets, utils
  features/
    auth/          # login, register, session
    jobs/          # public job browsing, job details, search/filter
    applications/  # job-seeker: apply flow, my applications
    profile/       # shared seeker/recruiter profile screens
    recruiter/     # recruiter dashboard, job CRUD, applicant management
    admin/         # admin dashboard, user/job/application management
```

## Roles

| Role | Can do |
|---|---|
| Guest | Browse jobs, view job details, register/login |
| Job Seeker | Apply to jobs, track applications, manage profile/resume |
| Recruiter | Post/edit/close jobs, review applicants, update application status |
| Admin | Manage users (activate/deactivate/delete), manage all jobs, view all applications, dashboard stats |

## Running locally

```bash
flutter pub get
flutter run
```

The app talks to the live backend by default (`lib/core/constants/api_constants.dart`). To point at a local backend instead, change `ApiConstants.baseUrl` — use `http://10.0.2.2:5000/api/v1` for the Android emulator, or your machine's LAN IP for a physical device. Note the live backend's CORS only allows configured web origins, so a local backend is needed for `flutter run -d chrome` unless that origin has been added there.

## Testing

```bash
flutter analyze   # static analysis
flutter test      # unit + widget tests (see test/)
```

`test/` contains a focused set of unit tests (formatters, query-param building, Dio-exception mapping) and widget tests (shared components: buttons, empty/error states, status badges) — not full app coverage, just automation smoke checks that run in CI on every push.

## CI/CD

`.github/workflows/deploy.yml` runs on every push to `test`:
1. `flutter analyze` + `flutter test`.
2. Builds a debug-signed release APK and publishes it as a GitHub Release (auto-tagged `v<version>+<run number>`).
3. Builds the Flutter web app and deploys it to GitHub Pages.

## Known platform limits

- Native file/image pickers (resume/company-logo/profile-photo upload) require a real device or emulator to exercise end-to-end — they're a no-op in headless/web-sandbox environments.
- The web build is a secondary target (useful for GitHub Pages/demo purposes); Android is the primary supported platform per the original spec.
