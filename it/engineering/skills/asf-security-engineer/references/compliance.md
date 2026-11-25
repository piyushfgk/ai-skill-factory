# Compliance reference

This is a starting map, not legal advice. Laws and standards change; confirm
current requirements with the official text and a qualified person before
relying on them.

## Which rules might apply

| Data or activity | Common frameworks (examples) | Typical obligations |
|---|---|---|
| Personal data of people in the EU/UK | GDPR, UK GDPR | Lawful basis, privacy notice, data subject rights, records of processing, breach notification, data processing agreements, transfers outside the region |
| Personal data elsewhere | For example CCPA/CPRA (California), LGPD (Brazil), DPDP Act (India), PIPEDA (Canada) | Notice, opt-out or consent rules, access and deletion requests, breach notice |
| Health data | For example HIPAA (US); health data is "special category" under GDPR | Access controls, audit logs, encryption, business associate agreements, minimum necessary use |
| Card payments | PCI DSS | Keep card data out of your systems (hosted payment pages or tokenisation) to shrink scope; secure what remains |
| Selling to businesses | SOC 2, ISO 27001 (often asked for by customers) | Documented controls with evidence over time |
| Accessibility | For example WCAG via national laws | Hand to `asf-frontend-engineer` |

## Compliance map

```markdown
| Requirement | Control in this product | Evidence | Owner | Gap |
|---|---|---|---|---|
| Breach notification within the legal deadline | Incident process, on-call contact | Incident runbook link | security | none |
| Delete user data on request | Admin delete flow + backup expiry | Test record, backup policy | backend | backups keep data 90 days: document it |
```

## Practical defaults

- Collect the least data that does the job; set retention periods and delete on schedule.
- Encrypt in transit everywhere and at rest for databases, backups and devices.
- Keep a list of processors (hosting, email, analytics, payments) with their agreements.
- Make access requests and deletions possible without engineering heroics.
- For payments, use a provider's hosted checkout or tokenisation so card numbers never touch your servers.
