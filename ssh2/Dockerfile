# Use a Debian slim base image
FROM debian:stable-slim

# Update packages and install OpenSSH server, sshpass, sudo, and coreutils (for ls)
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sshpass sudo coreutils

# Create the CTF user
ARG CTF_USER_ARG # Receives the value from docker-compose build --build-arg
# Directly use CTF_USER_ARG for useradd to ensure it's resolved
RUN useradd -m ${CTF_USER_ARG} -s /bin/bash
# Set ENV CTF_USER for later commands that might use it (e.g., echo to .bashrc)
ENV CTF_USER=${CTF_USER_ARG}

# Create the .ssh directory and set correct permissions for the CTF user
RUN mkdir /home/${CTF_USER}/.ssh
RUN chmod 700 /home/${CTF_USER}/.ssh

# Copy the public SSH key from the host's ctf-keys directory
COPY ctf-keys/ctf_key.pub /home/${CTF_USER}/.ssh/authorized_keys
RUN chmod 600 /home/${CTF_USER}/.ssh/authorized_keys
RUN chown -R ${CTF_USER}:${CTF_USER} /home/${CTF_USER}/.ssh

# Configure SSH
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set SSH session timeout to 1 minute (60 seconds of inactivity)
RUN echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
RUN echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

# ******************************************************************
# Configure sudoers for privilege escalation (ls, mount, poweroff)
# ******************************************************************

# ctfuser will have NOPASSWD for /usr/bin/ls, /usr/bin/mount, and /usr/sbin/poweroff
RUN echo "${CTF_USER} ALL=(root) NOPASSWD: /usr/bin/ls, /usr/bin/mount, /usr/sbin/poweroff" > /etc/sudoers.d/ctfuser_privs
RUN chmod 440 /etc/sudoers.d/ctfuser_privs # Correct permissions for sudoers.d

# ******************************************************************
# Disable history writing for root and ctfuser
# ******************************************************************
RUN echo "unset HISTFILE" >> /root/.bashrc
RUN echo "unset HISTSIZE" >> /root/.bashrc
RUN echo "unset HISTFILE" >> /home/${CTF_USER}/.bashrc
RUN echo "unset HISTSIZE" >> /home/${CTF_USER}/.bashrc
RUN chown ${CTF_USER}:${CTF_USER} /home/${CTF_USER}/.bashrc

# ******************************************************************
# SSH Configuration and Privilege Separation Directory
# ******************************************************************
# Create the privilege separation directory for SSH
RUN mkdir -p /run/sshd
RUN chmod 0755 /run/sshd


# ******************************************************************
# Final Flag
# ******************************************************************

# Add the final flag (accessible only as root)
ARG FLAG_TWO_CONTENT_ARG
ENV FLAG_TWO_CONTENT=${FLAG_TWO_CONTENT_ARG}
RUN echo "${FLAG_TWO_CONTENT}" > /root/flag2.txt
RUN chmod 400 /root/flag2.txt
RUN chown root:root /root/flag2.txt

EXPOSE 22

# Start SSH in foreground
CMD ["/usr/sbin/sshd", "-D"]
