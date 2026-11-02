# Docker workshop

> "It works on my machine" is not a deployment strategy.

Workshop by [Ilan-LP](https://github.com/Ilan-LP) for Epitech Lyon.
You will learn what Docker is, how it works under the hood, and then containerize a real stack step by step: an API, a React front, a Postgres database, and finally all of them together with Docker Compose.

## Goal

By the end of the workshop you can:

- explain the difference between an image and a container, and between a container and a VM
- write a `Dockerfile` that builds fast (layer cache) and small (multi-stage, alpine)
- run, inspect and debug a container (`run`, `logs`, `exec`, `ps`)
- persist data with volumes and expose services with port mapping
- describe a multi-service app in one `compose.yml` and start it with a single command

## Prerequisites

- Docker installed and running (Docker Desktop, or Docker Engine + the Compose plugin). Check with:
  ```bash
  docker --version
  docker compose version
  docker run --rm hello-world
  ```
- Git and a terminal
- Node.js is **not** required on your machine: everything runs in containers

## Repository content

| Path | What it is |
|---|---|
| `presentation.pptx` | The slides: what Docker is, how it works, the commands to know |
| `script.md` | The speaker script that goes with the slides, with timings (French) |
| `CHEATSHEET.md` | The Docker commands and Dockerfile instructions used today |
| `demo/` | Code used live during the presentation, with the commands to run |
| `projects/` | The 4 mini-projects you do yourself, from easiest to hardest |
| `solutions/` | Reference solutions, same layout as `projects/`. Try on your own first |

## The mini-projects

Each project has its own `README.md` and a `check.sh` script that tells you what is still missing.

| # | Project | You learn |
|---|---|---|
| 1 | [Containerize an API](projects/mini-project-1) | `Dockerfile`, layer cache, `.dockerignore`, `docker run -p` |
| 2 | [Multi-stage React build](projects/mini-project-2) | multi-stage builds, build args, nginx, image size |
| 3 | [API + Postgres with Compose](projects/mini-project-3) | `compose.yml`, service DNS, env files, named volumes |
| 4 | [Full stack](projects/mini-project-4) | networks, healthchecks, reverse proxy, dev override |

Do them in order: each one reuses what the previous one taught you.

## How to work

```bash
git clone https://github.com/Ilan-LP/workshop-docker.git
cd workshop-docker/projects/mini-project-1
cat README.md      # read the instructions
# edit the files with TODOs, then:
./check.sh
```

Stuck? Read the hints in the project README, ask a neighbour, then ask us. The solution is the last resort.

## Useful links

- [Docker getting started](https://docs.docker.com/get-started/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Docker Hub](https://hub.docker.com) (find official images: `node`, `nginx`, `postgres`...)
- [Play with Docker](https://labs.play-with-docker.com) (a free online playground if your setup breaks)
