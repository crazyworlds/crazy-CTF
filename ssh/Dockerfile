# Use a Debian slim base base
FROM debian:stable-slim

# Update packages and install OpenSSH server, sshpass, OpenJDK, and utilities
# Liferay requires Java. We'll use curl and unzip for download and extraction.
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sshpass \
    openjdk-8-jdk \
    curl \
    unzip \
    tar \
    xmlstarlet 

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

# Set SSH session timeout to 1 minute (60 seconds of inactivity)
RUN echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
RUN echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

# ******************************************************************
# Liferay Portal Configuration (CVE-2020-7961)
# ******************************************************************

# Define Liferay version and download URL
ENV LIFERAY_VERSION=7.0.0-m2
ENV LIFERAY_DOWNLOAD_URL=https://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.0%20M2/liferay-portal-tomcat-7.0-ce-m2-20141017162509960.zip

# Create installation directory
RUN mkdir -p /opt/liferay

# Download and extract Liferay Portal bundle with Tomcat
WORKDIR /tmp
RUN curl -L ${LIFERAY_DOWNLOAD_URL} -o liferay-portal.zip
RUN unzip liferay-portal.zip -d /opt/liferay/
# Ensure the move command matches the extracted folder name for M2
RUN mv /opt/liferay/liferay-portal-${LIFERAY_VERSION}/* /opt/liferay/
RUN rm liferay-portal.zip

# Set proper permissions (Liferay will run as root for CTF purposes)
RUN chown -R root:root /opt/liferay
RUN chmod -R 755 /opt/liferay

# Configure Tomcat to listen on all interfaces (0.0.0.0)
# This is often needed in Docker containers if Tomcat binds to localhost by default
RUN sed -i 's/address="localhost"/address="0.0.0.0"/' /opt/liferay/tomcat/conf/server.xml
# Set JAVA_HOME
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

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
RUN echo "ps aux | grep tomcat" >> /root/.bash_history # Modified for Tomcat
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
EXPOSE 22 8080

# Start SSH and Liferay/Tomcat in background as root
CMD ["sh", "-c", "/usr/sbin/sshd -D & /opt/liferay/tomcat/bin/catalina.sh run"]



