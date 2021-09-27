#!/usr/bin/env bash
set -e

if [[ -z $PROFILE ]]; then
  PROFILE='default'
fi

if [[ -z $REGION ]]; then
  REGION='us-east-1'
fi

echo "PROFILE: $PROFILE"
echo "REGION: $REGION"

AWS_REGION=$REGION
AWS_PROFILE=$PROFILE

TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
account_id=$(aws --profile ${AWS_PROFILE} sts get-caller-identity --query Account --output text)

repo_name=qc-batch-experiment

JOB_NAME=${repo_name}-${TIMESTAMP}-${RANDOM}
JOB_NAME=$(echo $JOB_NAME | sed 's/\//-/g')

IMAGEURI=${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com/${repo_name}:latest


# arn:aws:iam::080766874269:role/qcBatch-HCLS-SageMakerRole-us-east-1
SM_ROLE=arn:aws:iam::${account_id}:role/qcBatch-HCLS-SageMakerRole-${AWS_REGION}

echo "JOB_NAME: ${JOB_NAME}"

# "ContainerArguments.$": "States.Array('--instance-type', '', '--M', '1', '--device-arn', '', '--aws-region', '${AWS::Region}')",

instanceType=ml.c5.xlarge
M=1
D=4
deviceArn=arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6
awsRegion=$AWS_REGION

aws sagemaker --profile ${AWS_PROFILE} --region  ${AWS_REGION}   create-processing-job \
--processing-job-name ${JOB_NAME} \
--role-arn ${SM_ROLE} \
--processing-resources 'ClusterConfig={InstanceCount=1,InstanceType=$instanceType,VolumeSizeInGB=5}' \
--app-specification "ImageUri=${IMAGEURI},ContainerArguments=--instance-type,${instanceType},--M,${M},--D,${D},--device-arn,${deviceArn},--aws-region,${awsRegion}"


