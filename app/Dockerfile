# ==========================================
# STAGE 1: Builder
# ==========================================
FROM node:14-alpine AS builder
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .


# ==========================================
# STAGE 2: Minimal Runtime
# ==========================================
FROM node:14-alpine
WORKDIR /usr/src/app

# Copy ONLY the necessary files from the builder stage
# This leaves behind any npm caches or build tools
COPY --from=builder /usr/src/app ./

# The node:alpine image comes with a built-in non-root user named 'node'
# We switch to this user to satisfy the security requirement
USER node

EXPOSE 3000
CMD ["npm", "start"]
