    # Use a Debian slim image as base
    FROM debian:stable-slim

    # Update packages and install Apache2
    RUN apt-get update && apt-get install -y --no-install-recommends apache2

    # Enable Apache rewrite module
    # Copy our custom configuration files
    # Copy the "int" directory with specific contents
    COPY int/ /var/www/html/int/

    # Copy the private SSH key from the host's ctf-keys directory
    # NOW: The path is relative to the build context (ctf-root/)
    COPY ctf-keys/ctf_key /var/www/html/int/manage/id_rsa

    # Ensure the private key file has read permissions on the webserver
    RUN chmod 644 /var/www/html/int/manage/id_rsa
    RUN chown www-data:www-data /var/www/html/int/manage/id_rsa

    # Expose port 80
    EXPOSE 80

    # Command to start Apache in foreground
    CMD ["apache2ctl", "-D", "FOREGROUND"]