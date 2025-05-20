FROM debian:stable-slim
LABEL version="Ssh Server CTF"
LABEL description="Ssh Server to CTF content"
LABEL maintainer="The`{crazy"
RUN apt update 
RUN apt-get install -y --no-install-recommends openssh-server sshpass openjdk-17-jre-headless curl
RUN apt clean 
EXPOSE 22
ARG CTF_USER=ctfuser
RUN unset HISTFILE && rm -f /root/.bash_history /home/$CTF_USER/.bash_history
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
RUN mkdir /opt/metabase
WORKDIR /opt/metabase
RUN curl -L https://downloads.metabase.com/v0.46.6.0/metabase.jar -o metabase.jar
RUN chmod 644 metabase.jar
RUN unset HISTFILE && rm -f /root/.bash_history /home/$CTF_USER/.bash_history
COPY web-page /var/www/html/
RUN echo "FLAG_ONE{Metabase_Unauthenticated_RCE_to_Root}" > /root/flag1.txt
RUN chmod 400 /root/flag1.txt
RUN chown root:root /root/flag1.txt
RUN mkdir -p /root/.ssh && chown root:root /root/.ssh && chmod 700 /root/.ssh # Assicurati che esista e abbia permessi corretti

RUN echo "cat /etc/passwd" >> /root/.bash_history
RUN echo "ls -la /var/log/" >> /root/.bash_history
RUN echo "find / -name '*password*' 2>/dev/null" >> /root/.bash_history
RUN echo "ps aux | grep metabase" >> /root/.bash_history
RUN echo "sudo apt update" >> /root/.bash_history
RUN echo "ssh ctfuser@172.20.1.11 # Seems like the next internal jump box" >> /root/.bash_history
RUN echo "df -h" >> /root/.bash_history
RUN echo "history" >> /root/.bash_history
RUN chown root:root /root/.bash_history
RUN chmod 600 /root/.bash_history

EXPOSE 22 3000
CMD ["sh", "-c", "/usr/sbin/sshd -D & java -jar metabase.jar"]
