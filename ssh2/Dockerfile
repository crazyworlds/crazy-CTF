FROM debian:stable-slim
LABEL version="Web Server CTF"
LABEL description="Web Server to CTF content"
LABEL maintainer="The`{crazy"
RUN apt update 
RUN apt install –y openssh-server sshpass
RUN mkdir /var/run/sshd
RUN apt clean
ARG CTF_USER=ctfuser
RUN useradd -m $CTF_USER -s /bin/bash
RUN mkdir /home/$CTF_USER/.ssh
RUN chmod 700 /home/$CTF_USER/.ssh
COPY ../ctf-keys/ctf_key.pub /home/$CTF_USER/.ssh/authorized_keys
RUN chmod 600 /home/$CTF_USER/.ssh/authorized_keys
RUN chown -R $CTF_USER:$CTF_USER /home/$CTF_USER/.ssh
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config   # Invia un messaggio keep-alive ogni 60 secondi
RUN echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config    # Termina la sessione dopo 0 risposte (subito dopo il primo ClientAliveInterval)
RUN echo "ctfuser ALL=(root) NOPASSWD: /usr/bin/mount, /usr/sbin/poweroff" > /etc/sudoers.d/ctfuser_privs
RUN echo "ctfuser ALL=(root) NOPASSWD: /usr/bin/ls, /usr/bin/mount, /usr/sbin/poweroff" > /etc/sudoers.d/ctfuser_privs
RUN echo "FLAG_TWO{Bind_Mount_to_Root_on_RO}" > /root/flag2.txt
RUN chmod 400 /root/flag2.txt
RUN chown root:root /root/flag2.txt
RUN unset HISTFILE && rm -f /root/.bash_history /home/$CTF_USER/.bash_history
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
