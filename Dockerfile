# Sample Dockerfile for building a container image
# Customize this file based on your application needs

FROM alpine:3.19

# Add labels for container metadata
# Replace OWNER/REPO with your GitHub username/organization and repository name
LABEL org.opencontainers.image.source="https://github.com/OWNER/REPO"
LABEL org.opencontainers.image.description="Container image built from template"
LABEL org.opencontainers.image.licenses="MIT"

# Set working directory
WORKDIR /app

# Copy application files
# COPY . .

# Install any required packages (uncomment and customize as needed)
# RUN apk add --no-cache \
#     bash \
#     curl

# Set the entrypoint
CMD ["echo", "Hello from container-template!"]
