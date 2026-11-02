# ---- Stage 1: build ----
FROM node:22-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Vite reads VITE_* variables at BUILD time
ARG VITE_APP_NAME=docker-workshop
ENV VITE_APP_NAME=$VITE_APP_NAME

RUN npm run build

# ---- Stage 2: serve ----
# Only the static files make it to the final image: no Node, no node_modules
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
