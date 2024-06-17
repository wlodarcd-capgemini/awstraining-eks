#!/usr/bin/env bash
# Initial checks
if [ $? -ne 0 ]
then
  echo "ERROR: Associative arrays are not supported in bash versions older than 4.0. Please upgrade your bash." >&2
  exit 1
fi

set -e

if [ "$#" -lt 4 ]
then
  echo "Usage: $0 PROFILE REGION DIRECTORY COMMAND [options]" >&2
  exit 1
fi

if [ ! -d "$3" ]
then
  echo "ERROR: Directory $3 does not exist" >&2
  exit 1
fi

# allowed profiles with its respective environment
# update when adding new aws account
declare -A PROFILE2ENV
declare -A REGION2HUB

PROFILE2ENV[backend-test]="test"
REGION2HUB[eu-central-1]="emea"
REGION2HUB[us-east-1]="us"

# Load properties file
source 'wrapper.properties'

PROFILE=$1
REGION=$2
ENVIRONMENT=${PROFILE2ENV[$PROFILE]}
# remove trailing / from path if it exists, so that we are uniform when creating common tags
TARGET_PATH=${3%/}
COMMAND=$4
OPTIONS=${@:5}
HUB=${REGION2HUB[$REGION]}

# Check if UNIQUE_BUCKET_STRING is not empty and set unique state bucket suffix
if [ -n "$UNIQUE_BUCKET_STRING" ]; then
    BUCKET_SUFFIX="-${UNIQUE_BUCKET_STRING}"
else
    BUCKET_SUFFIX=""
fi

REMOTE_STATE_BUCKET="tf-state-${PROFILE}-${REGION}${BUCKET_SUFFIX}"

TERRAFORM_FILE_NAME="$(basename ${TARGET_PATH})"
STATE_FILE_KEY="${TERRAFORM_FILE_NAME}.tfstate"

# export common Terraform variables
export AWS_PROFILE=$PROFILE
export TF_VAR_remote_state_bucket=$REMOTE_STATE_BUCKET
export TF_VAR_region=${REGION}
export TF_VAR_profile=${PROFILE}
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
COMMON_TAGS="{\"app:hub\"=\"$HUB\", \"app:env\"=\"$ENVIRONMENT\", \"app:name\"=\"backend\", terraform-path=\"$TARGET_PATH\", terraform=\"true\"}"
export TF_VAR_common_tags=${COMMON_TAGS}

check_properties(){
  if [[ ${TARGET_PATH} == "common"* ]]
  then
      echo "INFO: Executing common main.tf from [ $TARGET_PATH ] on $REGION / $ENVIRONMENT"
      return
  fi

  if [[ ${TARGET_PATH} != *"${REGION}"* ]];then
     echo "ERROR: Execution path: '$TARGET_PATH' doesn't contain region defined as parameter: ['$REGION']" >&2
     exit 1
  fi

  set +e
  echo $TARGET_PATH | grep -q "${PROFILE}/"

  if [[ $? -ne 0 ]];then
     echo "ERROR: Execution path: '$TARGET_PATH' doesn't match 'profile' parameter. [profile:'$PROFILE']" >&2
     exit 1
  fi

  if [ "a" == "a$ENVIRONMENT" ]
  then
      echo "ERROR: Can not derive environment from profile [ $PROFILE ]. Please check your parameters."
      exit 1
  fi

  if [ "a" == "a$HUB" ]
  then
      echo "ERROR: Can not derive hub from region [ $REGION ] . Please check your parameters."
      exit 1
  fi
  set -e
}

# Checks tfstate file in target profile to avoid running a common module with not matching profile
check_tfstate_with_profile(){
    if [ -e  $TARGET_PATH/.terraform/terraform.tfstate ]
    then
        set +e
        grep -q "profile.*$PROFILE" $TARGET_PATH/.terraform/terraform.tfstate
        profile_check=$?
        grep -q "region.*$REGION" $TARGET_PATH/.terraform/terraform.tfstate
        region_check=$?
        grep -q "bucket.*${profile}-${region}" $TARGET_PATH/.terraform/terraform.tfstate
        bucket_check=$?
        if [[ $profile_check -ne 0 ]] || [[ $region_check -ne 0 ]] || [[ $bucket_check -ne 0 ]]
        then
            pth=$(echo $PATH | sed "s/\/$//g")
            echo "ERROR: terraform.tfstate file does not contain requested profile/region $PROFILE/$REGION." >&2
            current_time=$(date +%s)
            mv "$pth/.terraform/terraform.tfstate" "$pth/.terraform/terraform.tfstate_$current_time"
            echo "Old state was moved to $pth/.terraform/terraform.tfstate_$current_time as backup"
            echo "Please rerun the script"
            exit 1
        fi
        set -e
    fi
}

check_path_override() {
    if [[ $PATH == "common/"* ]]
    then
        set +e
        modpath=$(echo $PATH |  sed -r "s|common/[a-z]+/||")
        find environments -type d | grep -qe "^environments/$PROFILE/.*/$REGION/$modpath$"
        if [ $? -eq 0 ]
        then
            RED='\033[0;31m'
            NC='\033[0m' # No Color
            mypath=$(find environments -type d | grep "^environments/$PROFILE/.*/$REGION/$modpath$")
            printf "${RED}========================================================================\n" >&2
            echo "WARN: similar directory [ $mypath ] "
            echo "      found in environments directory for [ $PROFILE/$REGION ]" >&2
            echo "      Continue only if You are sure that it is not a specific version of common module." >&2
            printf "========================================================================${NC}\n" >&2
        fi
        set -e
    fi

}

# Checks
check_properties
check_tfstate_with_profile
check_path_override

# Ensure we're executing in the correct directory
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "${SCRIPT_DIR}"

# Go to target module path
cd "${TARGET_PATH}"

# Initialize Terraform
terraform get
terraform init -backend-config "bucket=${REMOTE_STATE_BUCKET}" -backend-config "key=${STATE_FILE_KEY}" -backend-config "region=${REGION}" -backend-config "profile=${PROFILE}" -var environment=${ENVIRONMENT} -var profile=${PROFILE} -var remote_state_bucket=${REMOTE_STATE_BUCKET} -var region=${REGION} -var shared_credentials_file="${SHARED_CREDENTIALS_FILE}" -lock=true

if [ "$COMMAND" != "init" ]
then
  echo "Running terraform command: $COMMAND"
  terraform ${COMMAND} -var remote_state_bucket=${REMOTE_STATE_BUCKET} -var region=${REGION} -var environment=${ENVIRONMENT} -var profile=${PROFILE} -var shared_credentials_file=${SHARED_CREDENTIALS_FILE} ${OPTIONS}
fi
