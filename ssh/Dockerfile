# Use Debian Bullseye slim base image
FROM debian:buster-20181112-slim



# Update packages and install OpenSSH server, sshpass, OpenJDK, and utilities
# Liferay requires Java. We'll use curl and unzip for download and extraction.
RUN touch /etc/apt/apt.conf.d/99verify-peer.conf  && echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Acquire { https::Verify-Peer false }"
RUN echo >>/etc/apt/apt.conf.d/99verify-peer.conf "APT{Ignore {"gpg-pubkey"; }};"


RUN echo "deb   [ allow-insecure=yes ]   https://snapshot.debian.org/archive/debian/20211105T145313Z/ buster main" > /etc/apt/sources.list
#RUN echo "deb   [ allow-insecure=yes ]   https://snapshot.debian.org/archive/debian-security/20211105T192626Z/ buster main" >> /etc/apt/sources.list
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated --no-install-recommends \
    openssh-server \
    procps \
    sshpass \
    curl \
    unzip \
    tar \
    gpg \
    wget

RUN apt-get install -y --allow-unauthenticated  redis-server redis

# Create the CTF user (read from environment variable)
ARG CTF_USER_ARG
RUN useradd -m ${CTF_USER_ARG} -s /bin/bash
ENV CTF_USER=${CTF_USER_ARG}

# Create the .ssh directory and set correct permissions for the CTF user
RUN mkdir /home/${CTF_USER}/.ssh
RUN chmod 700 /home/${CTF_USER}/.ssh

# Copy the public SSH key from the host's ctf-keys directory
COPY ctf-keys/ctf_key.pub /home/${CTF_USER}/.ssh/authorized_keys
RUN chmod 600 /home/${CTF_USER}/.ssh/authorized_keys
RUN chown -R ${CTF_USER}:${CTF_USER} /home/${CTF_USER}/.ssh

# Configure SSH to accept only key authentication (disable password)
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Allow root login with key (useful for your debugging)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sed -i 's/#PidFile \/var\/run\/sshd.pid/PidFile \/var\/sshd.pid/' /etc/ssh/sshd_config

# Set SSH session timeout to 1 minute (60 seconds of inactivity)
RUN echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
RUN echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config
# ******************************************************************
# Redis Server Configuration (CVE-2022-0543)
# ******************************************************************

# Configure Redis to listen on all interfaces (0.0.0.0)
# By default, Redis in Debian might bind to 127.0.0.1.
RUN sed -i 's/^bind 127.0.0.1 ::1/bind 0.0.0.0/' /etc/redis/redis.conf
# Ensure Redis runs as root for privilege escalation (NOT FOR PRODUCTION!)
# Redis usually runs as 'redis' user. We'll make it run as root.
# This requires modifying the systemd service or starting it directly.
# For simplicity in CTF, we'll start it directly as root in CMD.
# No password for simplicity in CTF
RUN sed -i 's/^# requirepass foobared/requirepass ""/' /etc/redis/redis.conf || true 

# ******************************************************************
# Fake .bash_history for clue and disable history writing
# ******************************************************************
# Ensure /root/.bash_history exists and is owned by root.
RUN mkdir -p /root/.ssh && chown root:root /root/.ssh && chmod 700 /root/.ssh

# Add fictitious commands and the clue for ssh-target-2 (read from environment variable)
ARG SSH_TARGET_2_PRIVATE_IP_ARG
ENV SSH_TARGET_2_PRIVATE_IP=${SSH_TARGET_2_PRIVATE_IP_ARG}

RUN echo "cat /etc/passwd" >> /root/.bash_history
RUN echo "ls -la /var/log/" >> /root/.bash_history
RUN echo "find / -name '*password*' 2>/dev/null" >> /root/.bash_history
RUN echo "ps aux | grep tomcat" >> /root/.bash_history 
RUN echo "sudo apt update" >> /root/.bash_history
RUN echo "ssh ${CTF_USER}@${SSH_TARGET_2_PRIVATE_IP} # Seems like the next internal jump box" >> /root/.bash_history
RUN echo "df -h" >> /root/.bash_history
RUN echo "history" >> /root/.bash_history
RUN chown root:root /root/.bash_history
RUN chmod 600 /root/.bash_history

# Disable history writing for root and ctfuser
RUN echo "unset HISTFILE" >> /root/.bashrc
RUN echo "unset HISTSIZE" >> /root/.bashrc
RUN echo "unset HISTFILE" >> /home/${CTF_USER}/.bashrc
RUN echo "unset HISTSIZE" >> /home/${CTF_USER}/.bashrc
RUN chown ${CTF_USER}:${CTF_USER} /home/${CTF_USER}/.bashrc

# Add the first flag (accessible as root after RCE)
ARG FLAG_ONE_CONTENT_ARG
ENV FLAG_ONE_CONTENT=${FLAG_ONE_CONTENT_ARG}
RUN echo "${FLAG_ONE_CONTENT}" > /root/flag1.txt
RUN chmod 400 /root/flag1.txt
RUN chown root:root /root/flag1.txt

# Expose necessary ports: 22 for SSH, 8080 for Liferay/Tomcat
EXPOSE 22 6379

# Start SSH and Liferay/Tomcat in background as root
CMD ["sh", "-c", " [ ! -d /run/sshd/ ] && (mkdir -p /run/sshd/) ; /usr/sbin/sshd -D & /usr/bin/redis-server /etc/redis/redis.conf --protected-mode no"]
