# Newman / Postman

Newman (`newman` npm package) is available for collection-based REST/GraphQL runs.

```bash
npm install -g newman
# or from qa/: npx newman run collection.json -e env.json
```

Place exported Postman collections under `qa/api/newman/collections/` (gitignored secrets in `*.local.json`).

Prefer Playwright `APIRequestContext` / Nest Jest + Supertest for in-repo GraphQL contracts (`api-testing` skill).
