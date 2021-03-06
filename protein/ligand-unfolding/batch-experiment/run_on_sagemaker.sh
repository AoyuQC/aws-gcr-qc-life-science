#!/usr/bin/env bash
set -e

AWS_CMD="aws"
if [[ -n $PROFILE ]]; then
  AWS_CMD="aws --profile $PROFILE"
fi

if [[ -z $REGION ]]; then
  REGION='us-east-1'
fi

echo "AWS_CMD: $AWS_CMD"
echo "REGION: $REGION"

AWS_REGION=$REGION

TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
account_id=$(${AWS_CMD} sts get-caller-identity --query Account --output text)

repo_name=qc-batch-experiment


IMAGEURI=${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com/${repo_name}:latest

# arn:aws:iam::080766874269:role/qcBatch-HCLS-SageMakerRole-us-east-1
SM_ROLE=arn:aws:iam::${account_id}:role/qcBatch-HCLS-SageMakerRole-${AWS_REGION}
awsRegion=$AWS_REGION

# "ContainerArguments.$": "States.Array('--instance-type', '', '--M', '1', '--device-arn', '', '--aws-region', '${AWS::Region}')",

instanceType=ml.c5.xlarge
M=1
D=4
deviceArn=arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6

deviceName=$(echo $deviceArn | egrep -o "[^/]+$")

echo "instanceType: $instanceType, M: $M, D: $D, deviceArn:$deviceArn, deviceName: $deviceName"
JOB_NAME=QC-${deviceName}-M${M}-D${D}-${instanceType}-${TIMESTAMP}-${RANDOM}
JOB_NAME=$(echo $JOB_NAME | sed "s#\.##g;s#_#-#g")
echo "JOB_NAME: ${JOB_NAME}"

${AWS_CMD} sagemaker --region  ${AWS_REGION}   create-processing-job \
--processing-job-name ${JOB_NAME} \
--role-arn ${SM_ROLE} \
--processing-resources "ClusterConfig={InstanceCount=1,InstanceType=$instanceType,VolumeSizeInGB=5}" \
--app-specification "ImageUri=${IMAGEURI},ContainerArguments=--instance-type,${instanceType},--M,${M},--D,${D},--device-arn,${deviceArn},--aws-region,${awsRegion}"


