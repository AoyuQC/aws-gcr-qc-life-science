#!/bin/bash

ReleaseVersion=$1

AWS_CMD="aws"
if [[ -n $PROFILE ]];then
  AWS_CMD="aws --profile $PROFILE"
fi

echo "AWS_CMD: $AWS_CMD"

$AWS_CMD s3 cp ./qc-batch.yaml s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/qc/ --acl public-read

if [[ -n $ReleaseVersion ]];then
  $AWS_CMD s3 cp ./qc-batch.yaml s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/qc/qc-batch-$ReleaseVersion.yaml --acl public-read
  echo ""
  echo "https://aws-gcr-rs-sol-workshop-ap-northeast-1-common.s3.ap-northeast-1.amazonaws.com/qc/qc-batch-$ReleaseVersion.yaml"
fi

echo ""
echo "https://aws-gcr-rs-sol-workshop-ap-northeast-1-common.s3.ap-northeast-1.amazonaws.com/qc/qc-batch.yaml"
echo ""