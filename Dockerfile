FROM    alpine

ENV     HOME /var/lib/tor
ENV     TOR_VERSION 0.2.8.8

RUN     apk add --no-cache git libevent-dev openssl-dev gcc make automake ca-certificates autoconf musl-dev && \
        mkdir -p /usr/local/src/ && \
        git clone https://git.torproject.org/tor.git /usr/local/src/tor && \
        cd /usr/local/src/tor && \
        ./autogen.sh && \
        ./configure \
            --disable-asciidoc \
            --sysconfdir=/etc \
            --disable-unittests && \
        make install -j 10 && \
        cd .. && \
        rm -rf tor && \
        apk add --no-cache python3 python3-dev && \
        python3 -m ensurepip && \
        rm -r /usr/lib/python*/ensurepip && \
        pip3 install --upgrade pip setuptools pycrypto && \
        apk del git libevent-dev openssl-dev make automake python3-dev gcc autoconf musl-dev && \
        apk add --no-cache libevent openssl

ADD     assets/entrypoint-config.yml /
ADD     assets/onions /usr/local/src/onions
ADD     assets/torrc /var/local/tor/torrc.tpl

RUN     mkdir -p /etc/tor/

RUN     pip install pyentrypoint==0.3.8

RUN     cd /usr/local/src/onions && python3 setup.py install

RUN     mkdir -p ${HOME}/.tor && \
        addgroup -S -g 107 tor && \
        adduser -S -G tor -u 104 -H -h ${HOME} tor

VOLUME  ["/var/lib/tor/hidden_service/"]

ENTRYPOINT ["pyentrypoint"]

CMD     ["tor"]
