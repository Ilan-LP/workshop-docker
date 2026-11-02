# Mini-project 4 - The full stack

Front (React + nginx), API (Node), database (Postgres): three containers, one command, and only one door open to the outside.

```
browser :8080 --> web (nginx) --/api/--> api (Node) --> db (Postgres)
                  [frontend]            [frontend+backend]  [backend]
```

## What you learn

Custom networks, network isolation, healthchecks, `depends_on` with `service_healthy`, reverse proxy with nginx, compose override files for development

## Instructions

1. Write `api/Dockerfile` and `web/Dockerfile` by reusing what you did in projects 2 and 3.
   Read `web/nginx.conf`: it forwards `/api/` to the `api` service.
2. `cp .env.example .env`
3. Fill in each `TODO` in `compose.yml`.
4. Start everything:
   ```bash
   docker compose up --build
   ```
5. Open <http://localhost:8080>, add a few notes, refresh the page.
6. Check your work:
   ```bash
   ./check.sh
   ```

## Constraints

- Only `web` publishes a port (8080). The API and the database must not be reachable from your machine
- The API starts only once Postgres is **healthy**
- `web` and `db` must not share a network
- Data survives `docker compose down`

## Hints

<details>
<summary>Healthcheck for Postgres</summary>

The image ships a tool called `pg_isready`. A healthcheck is a command run regularly inside the container: `test: ["CMD-SHELL", "pg_isready -U <user> -d <db>"]`. In a compose file, a literal `$` must be written `$$`.
</details>

<details>
<summary>depends_on with a condition</summary>

```yaml
depends_on:
  db:
    condition: service_healthy
```
</details>

<details>
<summary>How does nginx find "api"?</summary>

Docker runs a DNS server for each network. A service name resolves to the container IP, but only for services on a network you share.
</details>

## Bonus: development mode

Rebuilding an image after every change is slow. Fill in `compose.dev.yml` and run:

```bash
docker compose -f compose.yml -f compose.dev.yml up --build
```

Now open <http://localhost:5173>, edit `web/src/App.jsx` and watch the page update without rebuilding. Same for `api/server.js` (the API restarts by itself).

Why do we need the anonymous volume on `/app/node_modules`? Try without it and read the error.

## Solution

`solutions/mini-project-4/` (after you tried seriously).
