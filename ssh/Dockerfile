# Use a Debian slim base image
FROM debian:stable-slim

# Update packages and install OpenSSH server, sshpass, OpenJDK (Java Runtime Environment), and curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sshpass \
    apache2 \
    php \
    php-cli \
    php-curl \
    php-gd \
    php-json \
    php-mbstring \
    php-mysql \
    php-xml \
    php-zip \
    libapache2-mod-php \
    curl \
    unzip \
    tar


# Create the CTF user (read from environment variable)
ARG CTF_USER_ARG
# ENV CTF_USER=${CTF_USER_ARG} # Rimosso: useremo CTF_USER_ARG direttamente
RUN useradd -m ${CTF_USER_ARG} -s /bin/bash

# Create the .ssh directory and set correct permissions for the CTF user
RUN mkdir /home/${CTF_USER_ARG}/.ssh
RUN chmod 700 /home/${CTF_USER_ARG}/.ssh

# Copy the public SSH key from the host's ctf-keys directory
COPY ctf-keys/ctf_key.pub /home/${CTF_USER_ARG}/.ssh/authorized_keys
RUN chmod 600 /home/${CTF_USER_ARG}/.ssh/authorized_keys
RUN chown -R ${CTF_USER_ARG}:${CTF_USER_ARG} /home/${CTF_USER_ARG}/.ssh

# Configure SSH to accept only key authentication (disable password)
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Allow root login with key (useful for your debugging)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set SSH session timeout to 1 minute (60 seconds of inactivity)
RUN echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
RUN echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

# ******************************************************************
# FuelCMS Configuration (CVE-2018-16763)
# ******************************************************************

# Download a vulnerable version of FuelCMS (1.4.1 is vulnerable to CVE-2018-16763)
RUN curl -L https://github.com/daylightstudio/FUEL-CMS/archive/1.4.1.zip -o /tmp/fuelcms-1.4.1.zip
RUN unzip /tmp/fuelcms-1.4.1.zip -d /tmp/
RUN mv /tmp/FUEL-CMS-1.4.1/* /var/www/html/ # Move to Apache's default web root

# Set permissions for FuelCMS files
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 755 /var/www/html/

# Configure Apache for FuelCMS
# Enable Apache modules needed for FuelCMS (rewrite and PHP)
RUN a2enmod rewrite
RUN a2enmod php7.4 # Or the version installed by default (e.g., php8.2)

# Remove default Apache site config
RUN rm /etc/apache2/sites-available/000-default.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

# Create a new Apache site config for FuelCMS
COPY ssh/fuelcms.conf /etc/apache2/sites-available/fuelcms.conf
RUN a2ensite fuelcms.conf

# Ensure Apache runs as root for privilege escalation (NOT FOR PRODUCTION!)
RUN sed -i 's/User ${APACHE_RUN_USER}/User root/' /etc/apache2/apache2.conf
RUN sed -i 's/Group ${APACHE_RUN_GROUP}/Group root/' /etc/apache2/apache2.conf

# Clean up downloaded files
RUN rm /tmp/fuelcms-1.4.1.zip

# ******************************************************************
# Fake .bash_history for clue and disable history writing
# ******************************************************************
# Ensure /root/.bash_history exists and is owned by root.
RUN mkdir -p /root/.ssh && chown root:root /root/.ssh && chmod 700 /root/.ssh

# Add fictitious commands and the clue for ssh-target-2 (read from environment variable)
# Note: SSH_TARGET_2_PRIVATE_IP will be passed as an ARG during build
ARG SSH_TARGET_2_PRIVATE_IP_ARG
ENV SSH_TARGET_2_PRIVATE_IP=${SSH_TARGET_2_PRIVATE_IP_ARG} 

RUN echo "cat /etc/passwd" >> /root/.bash_history
RUN echo "ls -la /var/log/" >> /root/.bash_history
RUN echo "find / -name '*password*' 2>/dev/null" >> /root/.bash_history
RUN echo "ps aux | grep metabase" >> /root/.bash_history
RUN echo "sudo apt update" >> /root/.bash_history
RUN echo "ssh ${CTF_USER_ARG}@${SSH_TARGET_2_PRIVATE_IP} # Seems like the next internal jump box" >> /root/.bash_history
RUN echo "df -h" >> /root/.bash_history
RUN echo "history" >> /root/.bash_history
RUN chown root:root /root/.bash_history
RUN chmod 600 /root/.bash_history

# Disable history writing for root and ctfuser
RUN echo "unset HISTFILE" >> /root/.bashrc
RUN echo "unset HISTSIZE" >> /root/.bashrc
RUN echo "unset HISTFILE" >> /home/${CTF_USER_ARG}/.bashrc
RUN echo "unset HISTSIZE" >> /home/${CTF_USER_ARG}/.bashrc
RUN chown ${CTF_USER_ARG}:${CTF_USER_ARG} /home/${CTF_USER_ARG}/.bashrc

# Add the first flag (accessible as root after RCE) (read from environment variable)
ARG FLAG_ONE_CONTENT_ARG
ENV FLAG_ONE_CONTENT=${FLAG_ONE_CONTENT_ARG} 
RUN echo "${FLAG_ONE_CONTENT}" > /root/flag1.txt
RUN chmod 400 /root/flag1.txt
RUN chown root:root /root/flag1.txt

# Expose necessary ports: 22 for SSH and 3000 for Metabase (default)
EXPOSE 22 80

# Start SSH and Metabase in background as root
CMD ["sh", "-c", "/usr/sbin/sshd -D & /opt/activemq/bin/activemq console"]


