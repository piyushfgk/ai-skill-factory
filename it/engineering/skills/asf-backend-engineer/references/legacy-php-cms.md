# Older PHP applications and CMS sites

Many real sites run on an older PHP version, a CMS (for example WordPress,
Drupal, Joomla) or a framework release past its support date. Treat them with
care: they often have no tests, no staging and plugins nobody remembers adding.

## First look (read-only)

- PHP version in production vs the versions still getting security fixes.
- CMS core version, plugin and theme list with versions and last update dates.
- Custom code: themes, must-use plugins, `functions.php`-style hooks, cron jobs.
- Where config and secrets live (for example `wp-config.php`, `.env`) and
  whether they are in version control (they should not be).
- Hosting type: shared hosting, VPS, container. What runs PHP (PHP-FPM, a
  module), which web server, which database version.
- Backups: what, how often, where, and when a restore was last tested.

## Safe update path

1. Full backup (files and database) and a tested way to restore it.
2. Staging copy with production data (personal data masked if needed).
3. Update on staging in this order: backups plugin, core, plugins one by one,
   theme; check the site and the error log after each.
4. Raise PHP one supported minor version at a time on staging; fix
   deprecations shown in the logs.
5. Run smoke tests (with `asf-qa-engineer`): home, login, forms, checkout,
   admin, scheduled tasks.
6. Repeat on production in a window, with the backup ready.
7. Record versions before and after.

## Common fixes

- **White screen or 500:** read the PHP error log; disable the last-changed
  plugin by renaming its folder on staging first.
- **Changes not showing after an update:** theme or plugin assets enqueued
  without a version argument (set it to the theme version or the file's
  modification time), a page-cache plugin or server cache not purged, or a
  CDN caching HTML. Purge in that order: page cache, then CDN.
- **Slow pages:** page cache, object cache, image sizes, plugin count, slow
  database queries.
- **Hacked site:** treat as an incident with `asf-security-engineer`: take a
  copy for evidence, restore clean code from a known source, rotate every
  password and key, update everything, then find the entry point.

## When to move on

Suggest a migration plan (with `asf-cto`) when the runtime is past end of
life with no upgrade path, core cannot be updated without a rewrite, or the
hosting blocks security fixes. Migrate in stages: freeze features, move
hosting or runtime first, then refactor.
