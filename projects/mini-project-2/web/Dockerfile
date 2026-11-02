# Mini-project 2 - multi-stage build for the React app
# Stage 1 builds the app (needs Node). Stage 2 only serves static files (needs nginx).

# TODO 1: first stage, based on Node 22 alpine, named "build"
FROM ??? AS build

# TODO 2: install dependencies (cache-friendly order, like in mini-project 1)

# TODO 3: declare a build argument VITE_APP_NAME (default: docker-workshop)
#         and expose it as an environment variable so Vite can read it

# TODO 4: build the app (npm run build produces /app/dist)

# TODO 5: second stage, based on nginx alpine
FROM ???

# TODO 6: copy ONLY the built files from the first stage
#         into /usr/share/nginx/html

# nginx listens on port 80 by default
EXPOSE 80
