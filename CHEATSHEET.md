# Docker cheatsheet

## Images

```bash
docker build -t myapp .                 # build an image from ./Dockerfile
docker build -t myapp --build-arg KEY=value .
docker images                           # list local images
docker pull postgres:16-alpine          # download an image
docker rmi myapp                        # delete an image
docker history myapp                    # see the layers and their size
```

## Containers

```bash
docker run myapp                        # run (foreground)
docker run -d --name api -p 8080:3000 myapp   # detached, named, host 8080 -> container 3000
docker run --rm -it node:22-alpine sh   # throwaway interactive shell
docker run -e KEY=value myapp           # environment variable
docker run -v mydata:/var/lib/data myapp      # named volume
docker run -v "$(pwd)":/app myapp       # bind mount (your folder inside the container)

docker ps                               # running containers (-a for all)
docker logs -f api                      # follow logs
docker exec -it api sh                  # open a shell in a running container
docker stop api && docker rm api        # stop then remove
docker rm -f api                        # force remove
docker system prune                     # clean unused stuff (careful)
```

## Compose

```bash
docker compose up                       # create + start (foreground)
docker compose up -d --build            # detached, rebuild images
docker compose ps                       # status of the services
docker compose logs -f api              # logs of one service
docker compose exec db psql -U notes    # command in a running service
docker compose down                     # stop + remove containers and networks
docker compose down -v                  # ... and delete the volumes (data lost!)
docker compose -f compose.yml -f compose.dev.yml up   # merge two files
```

## Dockerfile instructions

| Instruction | Role |
|---|---|
| `FROM node:22-alpine` | base image (start of a stage) |
| `WORKDIR /app` | working directory for the next instructions |
| `COPY src dest` | copy files from the build context |
| `RUN npm ci` | run a command at **build** time (creates a layer) |
| `ENV KEY=value` | environment variable, available at build and run time |
| `ARG KEY=default` | variable available at **build** time only |
| `EXPOSE 3000` | documentation of the port (does not publish anything) |
| `USER node` | switch to a non-root user |
| `CMD ["node", "server.js"]` | default command at **run** time |

## Rules of thumb

- Copy `package*.json` and install **before** copying the source (layer cache)
- Always have a `.dockerignore` (`node_modules`, `.git`, `.env`)
- Pin versions: `node:22-alpine`, not `node:latest`
- Never put secrets in an image: use environment variables at run time
- One process per container
- A container is disposable, a volume is where data lives
