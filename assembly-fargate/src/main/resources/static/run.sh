#!/bin/bash

function checkSyntax(){
    if [[ $HUB != "EMEA" && $HUB != "US" && $HUB != "NONE" ]]; then
        echo "Unknown hub: $HUB"
        printSyntax
        exit 101
    elif [[ $STAGE != "TEST" && $STAGE != "CI" ]]; then
        echo "Unknown stage: $STAGE"
        printSyntax
        exit 102
    fi
}

function printSyntax() {
    echo "Syntax: run.sh"
    echo "Requires the HUB and STAGE environment variables to be properly set"
}

checkSyntax

HOME=$(pwd)

PARAMSTORE_ARGS=''
LOG4JFILE="log4j2_local.xml"
if [[ $HUB != "NONE" ]]; then
    PARAMSTORE_ARGS='-Dspring.config.import="aws-parameterstore:" -Daws.paramstore.enabled=true'
    LOG4JFILE="log4j2.xml"
fi

echo "Running JAVA application..."
set -x
sh -c "java -Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ConcGCThreads=8 -XX:ParallelGCThreads=8 -Djavax.net.ssl.trustStore=$HOME/config/$HUB-$STAGE/truststore.jks -Djavax.net.ssl.trustStorePassword=paaspass -Dcom.awstraining.backend.staging.hub=$HUB -Dcom.awstraining.backend.staging.environment=$STAGE -Dspring.profiles.active=$HUB-$STAGE $PARAMSTORE_ARGS -jar app.jar --logging.config=file:./config/$HUB-$STAGE/$LOG4JFILE"
