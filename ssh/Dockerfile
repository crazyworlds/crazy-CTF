# Use a Debian slim base image
FROM debian:stable-slim

# Update packages and install OpenSSH server, sshpass, OpenJDK (Java Runtime Environment), and curl
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sshpass openjdk-17-jre-headless curl

# Create the CTF user (read from environment variable)
ARG CTF_USER_ARG
ENV CTF_USER=${CTF_USER_ARG} 

RUN useradd -m ${CTF_USER} -s /bin/bash # Usa la variabile ENV

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

# Set SSH session timeout to 1 minute (60 seconds of inactivity)
RUN echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
RUN echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

# ******************************************************************
# Metabase Configuration (CVE-2023-38646)
# ******************************************************************

# Create a directory for Metabase
RUN mkdir /opt/metabase
WORKDIR /opt/metabase

# Download the vulnerable Metabase JAR version (v0.46.6.0)
# This version is vulnerable to CVE-2023-38646 (prior to 0.46.6.1)
RUN curl -L https://downloads.metabase.com/v0.46.6.0/metabase.jar -o metabase.jar

# Set permissions for Metabase JAR
RUN chmod 644 metabase.jar

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

# Add the first flag (accessible as root after RCE) (read from environment variable)
ARG FLAG_ONE_CONTENT_ARG
ENV FLAG_ONE_CONTENT=${FLAG_ONE_CONTENT_ARG}
RUN echo "${FLAG_ONE_CONTENT}" > /root/flag1.txt
RUN chmod 400 /root/flag1.txt
RUN chown root:root /root/flag1.txt

# Expose necessary ports: 22 for SSH and 3000 for Metabase (default)
EXPOSE 22 3000

# Start SSH and Metabase in background as root
CMD ["sh", "-c", "/usr/sbin/sshd -D & java -jar metabase.jar"]

