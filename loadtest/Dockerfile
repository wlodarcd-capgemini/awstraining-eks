FROM maven:3.9.6-eclipse-temurin-11-alpine

# Main Alpine repository
ARG REPOSITORY=https://dl-cdn.alpinelinux.org/alpine/edge/main/

# Update packages
RUN apk update --repository=$REPOSITORY

RUN apk add --no-cache less --repository=$REPOSITORY
RUN apk add --no-cache tzdata --repository=$REPOSITORY
RUN apk add --no-cache util-linux --repository=$REPOSITORY

# Install openssl and curl without vulnerabilities
RUN apk add --no-cache "openssl>=3.1.0-r1" --repository=$REPOSITORY
RUN apk add --no-cache "curl>=8.0.1-r0" --repository=$REPOSITORY

# Install aws-cli
RUN apk add --no-cache aws-cli --repository=$REPOSITORY

# Set GMT
RUN cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

# environment values
ENV GATLING_VERSION 3.9.2
ENV GATLING_HOME /gatling

WORKDIR /build

COPY target/backend-load-test.jar /build/target/backend-load-test.jar
COPY src/ /build/src
COPY src/main/resources/scripts/start_on_aws.sh .
RUN chmod +x start_on_aws.sh

ENTRYPOINT ["./start_on_aws.sh"]