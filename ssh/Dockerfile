# Use Debian Bullseye slim base image
FROM debian:bullseye-slim

# Update packages and install essential utilities first, including ca-certificates and debian-archive-keyring
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    debian-archive-keyring \     
    openssh-server \
    sshpass \
    curl \
    unzip \
    tar \
    xmlstarlet \
    gnupg \
    apt-transport-https \
    dirmngr 

# Force another apt-get update to ensure ca-certificates are picked up
RUN apt-get update

# ******************************************************************
# Installazione di Redis Server (versione vulnerabile a CVE-2022-0543)
# ******************************************************************
# Clean up default sources.list from the base image to avoid conflicts
RUN rm /etc/apt/sources.list

# Aggiungi il repository Debian Snapshot per Bullseye da una data precedente alla patch
# La patch per CVE-2022-0543 è stata rilasciata a marzo 2022 (Redis 6.0.16)
# Usiamo una data di snapshot precedente, ad esempio febbraio 2022
# La chiave è ora fornita da debian-archive-keyring
RUN echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://snapshot.debian.org/archive/debian/20220228T000000Z/ bullseye main" > /etc/apt/sources.list.d/snapshot.list
# Aggiungi anche il repository standard di Bullseye per le dipendenze
RUN echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list.d/debian.list
# Corretto l'URL del repository di sicurezza
RUN echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://security.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list.d/debian.list


# Pinna il pacchetto redis-server per favorire il repository snapshot, senza specificare la versione esatta
# Questo permette ad apt di scegliere la versione più alta disponibile dal repository snapshot
RUN echo "Package: redis-server" > /etc/apt/preferences.d/redis-pin
RUN echo "Pin: release a=bullseye, o=Debian, l=Debian, n=bullseye, c=main, v=20220228T000000Z" >> /etc/apt/preferences.d/redis-pin
RUN echo "Pin-Priority: 900" >> /etc/apt/preferences.d/redis-pin
# Aumenta la priorità del repository snapshot rispetto al default per Redis
RUN echo "APT::Default-Release \"bullseye\";" >> /etc/apt/apt.conf.d/00local-release

# Aggiorna i repository e installa redis-server
RUN apt-get update && \
    apt-get install -y --no-install-recommends redis-server

# Verifica la versione di Redis installata (per debug)
RUN redis-server --version || true

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

# ******************************************************************
# SSH Configuration and Privilege Separation Directory
# ******************************************************************
# Create the privilege separation directory for SSH
RUN mkdir -p /run/sshd
RUN chmod 0755 /run/sshd

# Configure SSH to accept only key authentication (disable password)
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# Allow root login with key (useful for your debugging)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

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
# Disable protected mode for easier exploitation in CTF
RUN sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
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
RUN echo "ps aux | grep redis" >> /root/.bash_history # Modified for Redis
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

# Expose necessary ports: 22 for SSH, 6379 for Redis
EXPOSE 22 6379

# Start SSH and Redis in background, ensuring SSH is the main foreground process
CMD ["sh", "-c", "redis-server /etc/redis/redis.conf & exec /usr/sbin/sshd -D"]