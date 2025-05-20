FROM debian:stable-slim 
LABEL version="Web Server CTF - 2"
LABEL description="Web Server to CTF content - 2" 
LABEL maintainer="The`{crazy"
RUN apt update 
RUN apt install –y apache2 
RUN apt install –y apache2-utils 
RUN apt clean 
EXPOSE 80
COPY int/ /var/www/html/int/
COPY ../ctf-keys/ctf_key /var/www/html/int/manage/id_rsa
CMD [“apache2ctl”, “-D”, “FOREGROUND”]