FROM phusion/baseimage:0.9.9
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
RUN apt-get update && apt-get install -y python-software-properties && add-apt-repository -y ppa:chris-lea/node.js
RUN curl http://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add -
RUN echo "deb http://repo.varnish-cache.org/ubuntu/ precise varnish-3.0" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y nodejs git g++ varnish
RUN useradd node

VOLUME ["/ghost"]

RUN mkdir -p /etc/service/ghost
ADD ghost.sh /etc/service/ghost/run
RUN mkdir -p /etc/service/varnish
ADD varnish.sh /etc/service/varnish/run
ADD default.vcl /etc/varnish/default.vcl

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8080
CMD ["/sbin/my_init"]
