# Live demo

The code in `app/` is a tiny Node HTTP server that prints its hostname and Node version.
It is already written: during the demo we only write the `Dockerfile` and run it.
The goal is to show what Docker does, not to type code.

## 0. Prove the point: no Node on the host needed

```bash
docker run --rm node:22-alpine node -v
docker run --rm node:20-alpine node -v      # another version, same machine, no install
```

## 1. First container, the hard way

```bash
cd demo/app
docker run --rm -it -v "$(pwd)":/app -w /app -p 3000:3000 node:22-alpine node server.js
# open http://localhost:3000, then Ctrl+C
```

## 2. Write the Dockerfile (live, 6 lines)

```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package.json .
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
```

(`app/Dockerfile.final` is the reference if the live typing goes wrong.)

## 3. Build, run, inspect

```bash
docker build -t demo .
docker images demo
docker history demo                 # the layers
docker run -d --name demo -p 3000:3000 demo
curl localhost:3000                 # hostname = container id
docker ps
docker logs demo
docker exec -it demo sh             # ls, ps, whoami, then exit
docker stop demo && docker rm demo
```

## 4. Show the layer cache

```bash
docker build -t demo .              # everything CACHED
echo "// change" >> server.js
docker build -t demo .              # only the layers after COPY server.js are rebuilt
```

## 5. Show that a container is disposable

```bash
docker run -d --name demo -p 3000:3000 demo
docker exec demo sh -c 'echo hi > /tmp/file && ls /tmp'
docker rm -f demo
docker run -d --name demo -p 3000:3000 demo
docker exec demo ls /tmp            # the file is gone
docker rm -f demo
```

This sets up the volumes slide: what must survive lives in a volume, not in the container.
