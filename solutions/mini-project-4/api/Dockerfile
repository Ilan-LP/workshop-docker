FROM node:22-alpine

WORKDIR /app

# Dependency files first: this layer is cached until package*.json changes
COPY package*.json ./
RUN npm ci --omit=dev

# Source code last: it changes often, so it must not invalidate the layers above
COPY . .

ENV NODE_ENV=production
EXPOSE 3000

# The official node image ships a non-root "node" user
USER node

CMD ["node", "server.js"]
