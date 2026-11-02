# Mini-project 3 - API + Postgres with Docker Compose

A notes API (`api/`) needs a Postgres database. Instead of two long `docker run` commands, you describe both services in one `compose.yml` and start everything with `docker compose up`.

## What you learn

`compose.yml`, services, `build` vs `image`, service-name DNS, `.env` files, named volumes, `depends_on`, init scripts

## Instructions

1. Write `api/Dockerfile` (same recipe as mini-project 1, from memory).
2. Create your `.env` file from the example:
   ```bash
   cp .env.example .env
   ```
3. Fill in each `TODO` in `compose.yml`.
4. Start the stack:
   ```bash
   docker compose up --build
   ```
5. In another terminal:
   ```bash
   curl localhost:3000/notes
   curl -X POST localhost:3000/notes -H 'Content-Type: application/json' -d '{"text":"my first note"}'
   ```
6. Check your work:
   ```bash
   ./check.sh
   ```

## Constraints

- `docker compose up` is the **only** command needed to start everything
- The database password must come from `.env`, not be written in `compose.yml`
- Notes must still be there after `docker compose down` then `docker compose up` (but not after `docker compose down -v`)
- The seed note from `init.sql` must exist on first start

## Hints

<details>
<summary>The API cannot reach the database at localhost</summary>

Inside the API container, `localhost` is the API container itself. Containers of the same compose project share a network where each service is reachable **by its service name**.
</details>

<details>
<summary>Environment variables from .env</summary>

Compose automatically reads a `.env` file next to `compose.yml`. Use `${VARIABLE}` inside `compose.yml`.
</details>

<details>
<summary>Named volume vs bind mount</summary>

`pgdata:/var/lib/postgresql/data` is a named volume (managed by Docker, declared in the top-level `volumes:` key). `./init.sql:/docker-entrypoint-initdb.d/init.sql` is a bind mount (a file from your machine). Add `:ro` to make it read-only.
</details>

<details>
<summary>The API crashes at startup</summary>

`depends_on` only waits for the db **container to start**, not for Postgres to be ready. The API retries by itself (read `waitForDb` in `server.js`). Next project does it properly with a healthcheck.
</details>

## Bonus

- Open a SQL shell: `docker compose exec db psql -U notes -d notes`, then `SELECT * FROM notes;`
- Run `docker volume ls` and find your volume. What happens to it on `down` and on `down -v`?
- Change `init.sql` and restart: why is the new content ignored? (hint: init scripts only run on an empty data directory)

## Solution

`solutions/mini-project-3/` (after you tried seriously).
