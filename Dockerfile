FROM nginx:1.25-alpine

# Add labels for better container management
LABEL maintainer="nginx-team"
LABEL version="1.0"
LABEL description="Nginx web server for Kubernetes deployment"

# nginx user already exists in base image (UID/GID 101)
# Just ensure proper permissions for nginx user

# Copy custom nginx configuration (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Create necessary directories and set permissions
RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/run /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx /var/log/nginx /var/run

# Copy custom HTML content (optional)
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Switch to non-root user
USER nginx

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
