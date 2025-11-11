# Multi-stage build for production-optimized frontend
FROM node:20-alpine AS base

WORKDIR /app

# Copy package files
COPY package*.json ./

# ============================================
# Development stage
# ============================================
FROM base AS development

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

# Expose Vite dev server port
EXPOSE 5173

# Start development server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ============================================
# Build stage
# ============================================
FROM base AS build

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

# Accept build argument for API URL
ARG VITE_API_URL=http://localhost:4000
ENV VITE_API_URL=$VITE_API_URL

# Build the application
RUN npm run build

# ============================================
# Production stage
# ============================================
FROM nginx:alpine AS production

# Copy built assets from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy config injection script and make it the entrypoint
COPY inject-config.sh /inject-config.sh
RUN chmod +x /inject-config.sh

# Expose port
EXPOSE 80

# Use inject-config.sh as entrypoint (it will start nginx)
ENTRYPOINT ["/inject-config.sh"]

