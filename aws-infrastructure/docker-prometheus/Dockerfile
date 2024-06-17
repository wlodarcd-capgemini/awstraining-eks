FROM        amazonlinux:2023

RUN         mkdir /prometheus
RUN         mkdir /prometheus/bin
VOLUME      /prometheus/download
VOLUME      /prometheus/data
VOLUME      /prometheus/config
VOLUME      /prometheus/rules
RUN         yum install -y aws-cli && yum install -y tar && yum install -y gzip && yum install -y procps && yum install -y wget
RUN         mkdir -p /tmp/prometheus
RUN         wget -nv -O /tmp/prometheus/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v2.40.7/prometheus-2.40.7.linux-amd64.tar.gz
RUN         wget -nv -O /prometheus/bin/prometheus-ecs-discovery-linux-amd64 https://github.com/teralytics/prometheus-ecs-discovery/releases/download/v1.4.1/prometheus-ecs-discovery-linux-amd64

COPY        scripts/install-prom.sh        /tmp/prometheus/install-prom.sh
COPY        scripts/prometheus.sh          /prometheus/bin/prometheus.sh
COPY        scripts/service-discovery.sh   /prometheus/bin/service-discovery.sh

RUN         chmod +x /tmp/prometheus/install-prom.sh
RUN         ls /tmp/prometheus/
RUN         /tmp/prometheus/install-prom.sh

COPY        prometheus.yml                 /prometheus/config/prometheus.yml

RUN         chmod +x /prometheus/bin/*

EXPOSE      9090
ENTRYPOINT  [ "/prometheus/bin/prometheus.sh" ]