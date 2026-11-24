# Mobile playbook

## Choosing an approach

| Approach | Good for | Trade-offs |
|---|---|---|
| Responsive web or PWA | Content and simple tools; no store needed | Limited device APIs and push on some platforms; no store presence |
| Cross-platform with a JS runtime (for example React Native with Expo) | Web-skilled teams, one codebase, over-the-air updates | Native modules for some features; performance tuning on heavy UIs |
| Cross-platform with its own renderer (for example Flutter) | Consistent custom UI on both platforms | Different language; platform look needs extra work |
| Shared logic, native UI (for example Kotlin Multiplatform) | Native feel with shared business logic | Two UI codebases |
| Fully native (Kotlin, Swift) | Best performance and newest platform features | Two codebases and skill sets |

## Offline and sync

```markdown
| Data | Cached? | Editable offline? | Conflict rule | UI while syncing |
|---|---|---|---|---|
| Profile | yes | yes | last write wins, server timestamp | "Saved on this device" badge |
| Orders | yes (last 50) | no | n/a | read-only banner |
```

- Queue writes with an ID so retries don't duplicate.
- Show sync state; never lose a user's input silently.
- Encrypt sensitive data at rest using the platform's secure storage.

## Release checklist

- [ ] Version name and build number bumped (build numbers from CI).
- [ ] Release notes written; store screenshots and listing current.
- [ ] Privacy details (data collected, tracking) match the app's real behaviour.
- [ ] Build uploaded to the internal or beta track and smoke-tested on real devices.
- [ ] Crash reporting and analytics events verified on the release build.
- [ ] Staged rollout plan: for example 5% → 20% → 50% → 100%, with crash and
      review thresholds that stop it.
- [ ] Previous build available to roll back to (or a hotfix path), and the
      API still supports it.
- [ ] Over-the-air updates only for changes the store rules allow, on a staged channel.

## Push notifications and deep links

- Register tokens after login and on token refresh; remove them on logout.
- Every notification and link opens a specific screen, including from a cold
  start and when logged out (log in, then continue).
- Let users control notification categories in the app.
