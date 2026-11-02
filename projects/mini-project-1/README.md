# Mini-project 1 - Containerize an API

A small Express API lives in `api/`. Your job: package it in a Docker image and run it as a container.

## What you learn

`FROM`, `WORKDIR`, `COPY`, `RUN`, `CMD`, layer cache, `.dockerignore`, `docker build`, `docker run -p`

## Instructions

1. Open `api/Dockerfile` and fill in each `TODO`.
2. Open `api/.dockerignore` and list what must not be sent to the build.
3. Build the image:
   ```bash
   cd api
   docker build -t mp1-api .
   ```
4. Run it and open <http://localhost:3000>:
   ```bash
   docker run --rm -p 3000:3000 mp1-api
   ```
5. Check your work (from this folder):
   ```bash
   ./check.sh
   ```

## Constraints

- The image must be **under 300 MB**
- The API must answer on `/` with the hello message and on `/health`
- `NODE_ENV` must be `production` inside the container
- Rebuilding after editing only `server.js` must **not** reinstall the dependencies (look at the build output: the `npm ci` step must say `CACHED`)

## Hints

<details>
<summary>Which base image?</summary>

Look at the tags of the official `node` image on Docker Hub. The ones ending with `-alpine` are much smaller than the default Debian-based ones.
</details>

<details>
<summary>Why copy package.json separately?</summary>

Docker caches each instruction as a layer. If a layer is unchanged, it is reused. Your source code changes all the time, your dependencies rarely. Put the rarely-changing things first.
</details>

<details>
<summary>npm install or npm ci?</summary>

`npm ci` installs exactly what is in `package-lock.json` (reproducible). `--omit=dev` skips the dev dependencies.
</details>

<details>
<summary>Non-root user</summary>

The official node image already contains a user called `node`. Which Dockerfile instruction switches to a user?
</details>

## Bonus

- Run the container with `-d --name api` and open a shell inside with `docker exec -it api sh`. Run `whoami` and `ls`.
- Change the port inside the container with an environment variable: `docker run -e PORT=4000 -p 4000:4000 mp1-api`.
- Compare `docker images` for `node:22` and `node:22-alpine`.

## Solution

`solutions/mini-project-1/` (after you tried seriously).
