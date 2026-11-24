# AI playbook

## Evals

```markdown
| ID | Input | Expected (or rubric) | Scoring | Tags |
|---|---|---|---|---|
| e1 | <real input> | <good answer or key facts> | exact / contains / schema valid / judge 1-5 | easy, billing |
```

- Start with 20 to 50 real cases, including hard and adversarial ones.
- Use automatic checks where possible (exact match, schema, contains facts);
  use a model-as-judge only with a clear rubric and spot-checks by a person.
- Track score, cost and latency per run; keep the baseline to compare.

## Model choice

```markdown
| Model / provider | Eval score | Cost per 1k requests | p95 latency | Context | Data terms | Notes |
|---|---|---|---|---|---|---|
```

Pick the cheapest option that meets the quality bar, and re-check when
providers release new models.

## Retrieval (RAG)

- Chunk by meaning (sections, paragraphs) with overlap; keep source and date.
- Combine keyword and vector search when names, codes or exact terms matter.
- Re-rank the top results; pass only what is needed; ask for citations.
- Evaluate retrieval separately: does the right chunk appear in the top results?
- Re-index on content change; delete chunks when the source is deleted.

## Guardrails

| Risk | Defence |
|---|---|
| Prompt injection from documents or web pages | Treat retrieved text as data; separate it clearly; restrict tools available while processing it |
| Harmful or off-topic output | System instructions, output checks, refusal path |
| Wrong structured output | Schema validation, retry with the error, then fallback |
| Leaking private data | Filter retrieval by the user's permissions; never mix tenants |
| Runaway cost | Max tokens, rate limits per user, budget alerts |
| Provider outage | Timeout, retry, second provider or graceful "try later" |

## MCP servers for AI clients

Expose a few well-named tools with precise descriptions and input schemas;
prefer read-only tools; return compact results; document what each tool can
change. Tool descriptions are loaded into every session, so keep them short.
