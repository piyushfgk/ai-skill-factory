# Doc templates

## README

```markdown
# <Project name>

<One sentence on what it does and for whom.>

## Quick start
1. <install>
2. <configure: copy .env.example to .env and set ...>
3. <run>, then open <http://localhost:PORT>

## Usage
<the most common task, with an example>

## Development
<tests, lint, how to contribute>

## Deployment
<link to the runbook>

## License
```

## Runbook

```markdown
# Runbook: <task or alert>

**Owner:** <team or role> · **Last checked:** <date> · **Tier:** read-only | change | destructive

## When to use
<symptom or trigger>

## Before you start
- Access needed: <role, not names or secrets>
- Read the site profile for host aliases and approvals.

## Steps
1. Check: `<command>`. Expected: `<output>`.
2. Act: `<command>`.
3. Verify: `<command>`. Expected: `<output>`.

## Roll back
1. `<command>`

## Escalate
<when, to whom (role), with what information>
```

## Hand-off note

```markdown
# Hand-off: <work item>

- **What changed:** <files, systems, settings>
- **Why:** <link to issue or decision>
- **How it was checked:** <commands, tests, results>
- **State now:** <done / partly done; what is running where>
- **Open items and risks:** <list with owners>
- **Next step:** <one clear action>
```

## Verification note

```markdown
# Verification: <change>

| Check | Command or method | Expected | Actual | Pass |
|---|---|---|---|---|
| Service is up | `curl -fsS https://example.com/health` | 200 OK | 200 OK | ✓ |

**Checked at:** <date and time with time zone>, by <person or agent>
```

## Release notes

```markdown
# <Version> – <date>

## New
- <what users can now do>

## Improved
- <what got better>

## Fixed
- <what was broken, in user terms>

## Action needed
- <anything users or admins must do, such as config changes>
```
