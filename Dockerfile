FROM resin/rpi-raspbian:latest
MAINTAINER Diego Peralta <diego.peralta.dev@gmail.com>

ENV tors=25
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN echo 'deb http://deb.torproject.org/torproject.org jessie main' | tee /etc/apt/sources.list.d/torproject.list
RUN gpg --keyserver keys.gnupg.net --recv 886DDD89
RUN gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tor polipo haproxy libssl-dev wget curl git build-essential zlib1g-dev libyaml-dev libssl-dev && \
    ln -s /lib/x86_64-linux-gnu/libssl.so.1.0.0 /lib/libssl.so.1.0.0

RUN update-rc.d -f tor remove
RUN update-rc.d -f polipo remove

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -L https://get.rvm.io | bash

RUN bash -c "source /usr/local/rvm/scripts/rvm && rvm install 2.1"    
RUN bash -c "source /usr/local/rvm/scripts/rvm && gem install excon -v 0.44.4"

ADD start.rb /usr/local/bin/start.rb
RUN chmod +x /usr/local/bin/start.rb

ADD newnym.sh /usr/local/bin/newnym.sh
RUN chmod +x /usr/local/bin/newnym.sh

ADD haproxy.cfg.erb /usr/local/etc/haproxy.cfg.erb
ADD uncachable /etc/polipo/uncachable

EXPOSE 5566 4444

CMD bash -c "source /usr/local/rvm/scripts/rvm && ruby /usr/local/bin/start.rb"
