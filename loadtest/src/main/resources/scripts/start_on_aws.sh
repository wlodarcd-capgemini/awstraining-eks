#!/bin/bash

export JAVA_OPTS="-Durl=$loadUrl -DdurationRampUpSeconds=$loadDurationRampUpSeconds -DdurationSeconds=$loadDurationSeconds -DgetAllStatesRequestPerSecond=$loadGetAllStatesRequestPerSecond"

echo $JAVA_OPTS

function help_text {
    cat <<EOF
    Usage: $0 [ -p|--profile PROFILE ] [ -r|--report-bucket REPORT_BUCKET ] [-h]
        PROFILE         (optional) The profile to use from ~/.aws/credentials.
        REPORT_BUCKET   (required) name of the S3 bucket to upload the reports to. Must be in same AWS account as profile.
                                   It must be provided.
EOF
    exit 100
}

while [ $# -gt 0 ]; do
    arg=$1
    case $arg in
        -h|--help)
            help_text
        ;;
        -p|--profile)
            export AWS_DEFAULT_PROFILE="$2"
            shift; shift
        ;;
        -r|--report-bucket)
            REPORT_BUCKET="$2"
            shift; shift
        ;;
        *)
            echo "ERROR: Unrecognised option: ${arg}"
            help_text
            exit 101
        ;;
    esac
done

if [ -z "$REPORT_BUCKET" ]
    then
        echo "Report bucket required. Please make sure its empty."
        help_text
        exit 102
fi

## Clean reports
cd /build || { echo "Failure"; exit 1; }

rm -rf target/gatling/*

#run tests
java -cp target/backend-load-test.jar $JAVA_OPTS io.gatling.app.Gatling -s backend.BackendSimulation

#go one directory back
cd ..

#zip simulation results
filename=$(date +%Y-%m-%d_%H-%M-%S)_$HOSTNAME-result.tar.gz
tar -czvf ${filename} gatling/results


#Upload reports
aws s3 cp ${filename} s3://${REPORT_BUCKET}/${filename}

# block
tail -f /dev/null