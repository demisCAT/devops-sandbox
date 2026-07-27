# ---- Stage 1: Build dependencies ----
FROM node:18-alpine AS builder

WORKDIR /app

# Copy only package files first (so npm install is cached unless they change)
COPY package*.json ./

# Install ALL dependencies (including devDependencies, needed for tests in CI)
RUN npm ci --include=dev

# Copy the rest of the source code
COPY . .

# ---- Stage 2: Production image ----
FROM node:18-alpine

WORKDIR /app

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only what's needed from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/server.js ./server.js

# Switch to the non-root user
USER appuser

# Tell Docker the app listens on this port (doesn't actually open it)
EXPOSE 3000

# Set the command to run when container starts
CMD ["node", "server.js"]
