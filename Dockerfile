FROM debian:buster-slim
# must use >buster version, to solve the issue "`GLIBC_2.25' not found"

RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

# install dependencies
# libatomic1 is necessary to provide`libatomic.so.1`
RUN set -ex \
        && apt-get update \
        && apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu gpg wget libatomic1 \
        && rm -rf /var/lib/apt/lists/*

WORKDIR /bitcoin_data

ENV BITCOIN_VERSION 1.0.7.beta
ENV BITCOIN_URL https://download.bitcoinsv.io/bitcoinsv/1.0.7.beta/bitcoin-sv-1.0.7.beta-x86_64-linux-gnu.tar.gz

# install bitcoin binaries
RUN set -ex \
        && cd /tmp \
        && wget -qO bitcoin.tar.gz "$BITCOIN_URL" \
        && tar -xzvf bitcoin.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
        && rm -rf /tmp/*

ENV BITCOIN_DATA /data
RUN mkdir "$BITCOIN_DATA" \
        && chown -R bitcoin:bitcoin "$BITCOIN_DATA" \
        && ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin \
        && chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin
VOLUME /data

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8332 8333 18332 18333 28332
CMD ["bitcoind"]
