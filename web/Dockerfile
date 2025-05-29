# Use a Debian slim image as base
FROM debian:stable-slim

# Update packages and install Apache2
RUN apt-get update && apt-get install -y --no-install-recommends apache2

RUN a2enmod rewrite

RUN a2enmod include

RUN rm /etc/apache2/sites-available/000-default.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

COPY web/conf/000-default.conf /etc/apache2/sites-available/000-default.conf

# Enable our virtual host
RUN a2ensite 000-default.conf

# Copy our website files to Apache's default root directory
COPY web/web-page/index.shtml /var/www/html/index.shtml

# Expose port 80, the standard HTTP port
EXPOSE 80

# Command to start Apache in foreground, necessary for Docker containers
CMD ["apache2ctl", "-D", "FOREGROUND", "-e", "debug"]
