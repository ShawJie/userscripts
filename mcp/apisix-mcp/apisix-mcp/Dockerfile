FROM debian:12.10-slim

COPY ./bin /data/bin

WORKDIR /data

RUN apt update \
    && apt install -y sudo curl wget git jq tar make gnupg2 \
    && bin/apisix_conf.sh

CMD ["bash"]
