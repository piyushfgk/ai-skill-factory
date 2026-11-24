# Routing tests

Each `*.md` file here is a **made-up** project brief with the skills its
words should pull in (`expect`) and the skills they should not (`reject`).
`scripts/check_routing.py` matches each brief against every skill's
`metadata.signals` and fails when a case is not met. `scripts/validate.sh`
runs it.

Rules for cases:

- Briefs are invented. Do not paste a real client's brief, names, hosts or
  accounts.
- Keep each brief to a few sentences, in the words a user would type.
- When you change a skill's signals, run `./scripts/check_routing.py -v` to
  see every match.
