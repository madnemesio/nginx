FROM nginx:alpine

# Copy static assets
COPY src/index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Healthcheck for best practices
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -b -O /dev/null http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
