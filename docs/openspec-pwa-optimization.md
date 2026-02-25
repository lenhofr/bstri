# OpenSpec Feature: PWA Optimization

## Status
Completed

## Summary
Implement Progressive Web App capabilities for the Next.js static site so users can install it, load key routes quickly, and keep core content usable with limited or no network connectivity.

## Current State
- Next.js app is statically exported (`output: 'export'`).
- No web app manifest is defined.
- No service worker is registered.
- No explicit offline fallback or cache/update strategy exists.

## Goals
1. Pass Lighthouse installability checks for a production deploy.
2. Support offline fallback for core routes and static assets.
3. Define safe cache/update behavior that avoids stale-content confusion.
4. Keep the implementation compatible with static hosting on S3 + CloudFront.

## Non-Goals
- Push notifications and background sync in the initial rollout.
- Full offline support for dynamic/admin data mutations.

## Requirements

### R1: Web App Manifest + Icons
- Add a manifest with `name`, `short_name`, `description`, `start_url`, `display`, `theme_color`, and `background_color`.
- Set `start_url` to `/scoring` so opening the installed app lands on the scoring page by default.
- Provide icon assets (including maskable icon) for install prompts.
- Ensure `<head>` metadata references manifest and theme color.

### R2: Service Worker + Offline Support
- Register a service worker in production builds only.
- Precache an app-shell baseline (home + static assets needed for navigation chrome).
- Provide an offline fallback page/route for failed navigation requests.

### R3: Runtime Caching Strategy
- Cache-first for immutable static assets (hashed JS/CSS/fonts/images).
- Stale-while-revalidate for content pages where freshness matters.
- Network-first (or bypass cache) for admin/scoring APIs to avoid stale writes.

### R4: Update Lifecycle
- Detect service worker updates and provide a clear refresh flow.
- Avoid silent behavior changes during active user sessions.

### R5: Deploy/Hosting Requirements
- Serve over HTTPS.
- Ensure CloudFront/S3 headers do not block `manifest.webmanifest` or `sw.js`.
- Configure cache headers so service worker and manifest updates propagate safely.

### R6: Validation
- Run Lighthouse PWA audit against production-like environment.
- Verify installability and offline behavior on:
  - Android Chrome (install prompt and launch)
  - iOS Safari (Add to Home Screen behavior)

## Completion Notes
- Implemented in three merged phases: manifest/icons, service worker + offline fallback, then runtime cache policy + update prompt.
- Production now serves `manifest.webmanifest` and `sw.js` with the configured `/scoring` start route and caching behavior.
- Manual Android/iOS install/offline/update checks were completed and accepted.

## Approved Decisions
1. **Service worker approach:** start with `next-pwa` (Workbox-backed) to reduce custom SW maintenance risk.
2. **Default launch route:** manifest `start_url` is `/scoring`.
3. **Offline scope (initial):** core public routes and static assets only; admin/scoring writes remain network-dependent.
4. **Caching policy:** cache-first for immutable static assets, stale-while-revalidate for read-only content pages, network-first/bypass for admin and scoring write paths.
5. **Update UX:** show a refresh prompt when a new SW version is waiting; apply update on user confirmation.
6. **Validation gate:** ship only after Lighthouse installability checks pass and manual Android/iOS install+offline checks pass.

## Implementation Tasks
1. Add manifest + icon set in `web/public` and wire metadata in app layout.
2. Introduce service worker generation/registration (manual or plugin approach).
3. Add offline fallback page and route handling in service worker.
4. Define cache buckets and policies per asset/data class.
5. Add update UX (refresh available notification/flow).
6. Validate with Lighthouse and device checks; document results.

## Acceptance Criteria
- Launching the installed app opens at `/scoring` by default.
- App is installable from supported browsers.
- Offline navigation to previously visited core pages works with fallback for misses.
- No stale admin write behavior introduced by caching.
- Lighthouse installability-related checks show no critical failures.
