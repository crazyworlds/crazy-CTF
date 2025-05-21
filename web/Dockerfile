FROM debian:stable-slim
LABEL version="Web Server CTF"
LABEL description="Web Server to CTF content"
LABEL maintainer="The`{crazy"
RUN apt update 
RUN apt install –y apache2 
RUN apt install –y apache2-utils 
RUN apt clean 
EXPOSE 80
COPY web-page /var/www/html/
CMD [“apache2ctl”, “-D”, “FOREGROUND”]
