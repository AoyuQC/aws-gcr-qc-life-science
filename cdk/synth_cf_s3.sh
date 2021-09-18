#!/bin/bash 

ReleaseVersion=$1

AWS_CMD="aws"
CDK_CMD='cdk'
if [[ -n $PROFILE ]];then
  AWS_CMD="aws --profile $PROFILE"
  CDK_CMD="cdk --profile $PROFILE"
fi

echo "AWS_CMD: $AWS_CMD"

$CDK_CMD synth > gcr-sol-qc.yaml
$AWS_CMD s3 cp ./gcr-sol-qc.yaml s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/qc/ --acl public-read

if [[ -n $ReleaseVersion ]];then
  $AWS_CMD s3 cp ./gcr-sol-qc.yaml s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/qc/gcr-sol-qc-$ReleaseVersion.yaml --acl public-read
  echo ""
  echo "https://aws-gcr-rs-sol-workshop-ap-northeast-1-common.s3.ap-northeast-1.amazonaws.com/qc/gcr-sol-qc-$ReleaseVersion.yaml"
fi

echo ""
echo 'https://aws-gcr-rs-sol-workshop-ap-northeast-1-common.s3.ap-northeast-1.amazonaws.com/qc/gcr-sol-qc.yaml'
echo ""