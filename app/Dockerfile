# ==========================================
# STAGE 1: Builder
# ==========================================
FROM node:20-alpine AS builder
WORKDIR /usr/src/app

# Force Alpine to install the latest security patches
RUN apk update && apk upgrade --no-cache

COPY package*.json ./
RUN npm install

COPY . .

# ==========================================
# STAGE 2: Minimal Runtime
# ==========================================
FROM node:20-alpine
WORKDIR /usr/src/app

# Force Alpine to install the latest security patches here too
RUN apk update && apk upgrade --no-cache

COPY --from=builder /usr/src/app ./

USER node
EXPOSE 3000
CMD ["npm", "start"]
