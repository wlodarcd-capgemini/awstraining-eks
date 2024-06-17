FROM amazoncorretto:17-alpine3.16

# Default ports to expose
# 8081: http
EXPOSE 8081

USER 0

RUN apk add --no-cache aws-cli jq bash

# Initialize the configurable environment variables
ENV HOME_DIR=/backend

RUN mkdir ${HOME_DIR}

WORKDIR ${HOME_DIR}

ADD assembly-fargate/target/app.jar .
ADD assembly-fargate/target/run.sh .
ADD assembly-fargate/target/config config
ADD assembly-fargate/target/fargate fargate

RUN chmod +x run.sh &&\
    chown -R 1000:1000 ${HOME_DIR}
USER 1000

ENTRYPOINT [ "sh", "-c", "${HOME_DIR}/run.sh" ]
