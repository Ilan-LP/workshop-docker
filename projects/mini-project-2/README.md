# Mini-project 2 - Multi-stage build for a React app

A React (Vite) app lives in `web/`. To build it you need Node and hundreds of MB of `node_modules`. To **serve** it you only need a few static files. A multi-stage build keeps the first part out of the final image.

## What you learn

Multi-stage builds (`FROM ... AS`, `COPY --from`), build arguments (`ARG`), serving static files with nginx, image size

## Instructions

1. Open `web/Dockerfile` and fill in each `TODO`.
2. Fill in `web/.dockerignore`.
3. Build with a build argument and run on port 8080:
   ```bash
   cd web
   docker build -t mp2-web --build-arg VITE_APP_NAME=Minilan .
   docker run --rm -p 8080:80 mp2-web
   ```
4. Open <http://localhost:8080>: the page must say `Hello from Minilan`.
5. Check your work (from this folder):
   ```bash
   ./check.sh
   ```

## Constraints

- The final image must be **under 120 MB** and must **not contain Node**
- The build argument `VITE_APP_NAME` must end up in the page
- Two `FROM` in the Dockerfile, the first one named `build`

## Hints

<details>
<summary>Why is the name not changing at runtime?</summary>

Vite replaces `import.meta.env.VITE_*` while building, the value is written into the JavaScript bundle. So the variable must exist at **build** time: that is what `ARG` is for, and then Vite reads it from the environment (`ENV`).
</details>

<details>
<summary>Where does nginx look for files?</summary>

The official nginx image serves `/usr/share/nginx/html`. And Vite writes its output in `dist/`.
</details>

<details>
<summary>COPY from another stage</summary>

`COPY --from=<stage name> <path in that stage> <path in the current stage>`
</details>

## Bonus

- Build only the first stage and look at its size: `docker build --target build -t mp2-build .` then `docker images`. That is what you did **not** ship.
- Rebuild with another name and check the page changes.
- Run `docker history mp2-web` and find the layer that holds your static files.

## Solution

`solutions/mini-project-2/` (after you tried seriously).
