# Use a Debian slim image as base
FROM debian:stable-slim

# Update packages and install Apache2
RUN apt-get update && apt-get install -y --no-install-recommends apache2

# Copy our website files to Apache's default root directory
COPY web/web-page/ /var/www/html/

# Expose port 80, the standard HTTP port
EXPOSE 80

# Command to start Apache in foreground, necessary for Docker containers
CMD ["apache2ctl", "-D", "FOREGROUND"]
