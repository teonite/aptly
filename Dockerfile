FROM phusion/baseimage:0.9.22
MAINTAINER Andrzej Piasecki "apiasecki@teonite.com"

ENV DEBIAN_FRONTEND noninteractive

# Add Aptly repository
RUN echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460

# Add Nginx repository
RUN echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62

# Update APT repository and install packages
RUN apt-get -q update                  \
 && apt-get -y --force-yes install aptly           \
                       bzip2           \
                       gnupg           \
                       gpgv            \
                       graphviz        \
                       nginx           \
                       wget            \
                       xz-utils        \
                       bash-completion && \
    apt-get purge -y --auto-remove &&\
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install Aptly Configuration
COPY assets/aptly.conf /etc/aptly.conf

# Enable Aptly Bash completions
RUN wget https://raw.githubusercontent.com/smira/aptly/master/bash_completion.d/aptly \
  -O /etc/bash_completion.d/aptly \
  && echo "if ! shopt -oq posix; then\n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then\n\
    . /usr/share/bash-completion/bash_completion\n\
  elif [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
  fi\n\
fi" >> /etc/bash.bashrc

# Install Nginx Config
COPY assets/nginx.conf.sh /opt/nginx.conf.sh

# Install scripts
COPY assets/*.sh /opt/

RUN mkdir /etc/service/aptly
ADD assets/aptly_serve.sh /etc/service/aptly/run

RUN mkdir /etc/service/nginx
ADD assets/run_nginx.sh /etc/service/nginx/run

# Bind mount location
VOLUME [ "/opt/aptly" ]

EXPOSE 8080

EXPOSE 80

# Execute Startup script when container starts
ENTRYPOINT [ "/opt/startup.sh" ]
