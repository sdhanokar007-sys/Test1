# Stage 1: Build the React Application
FROM node:20-alpine AS builder
WORKDIR /app

# Copy dependency manifests and install them
COPY package*.json ./
RUN npm ci

# Copy application source code and generate the production build
COPY . .
RUN npm run build

# Stage 2: Serve the Build Artifacts via Nginx
FROM nginx:alpine

# Remove default static landing pages
RUN rm -rf /usr/share/nginx/html/*

# Copy build artifacts from the compiler stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom Nginx configuration to support React Router SPA navigation
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
