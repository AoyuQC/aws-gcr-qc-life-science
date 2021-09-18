#!/bin/bash

ReleaseVersion=$1

aws --profile rsops s3 cp ./qc-batch.yaml s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/qc/ --acl public-read

if [[ -n $ReleaseVersion ]];then
  aws --profile rsops s3 cp ./qc-batch.yaml s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/qc/qc-batch-$ReleaseVersion.yaml --acl public-read
  echo ""
  echo "https://aws-gcr-rs-sol-workshop-ap-northeast-1-common.s3.ap-northeast-1.amazonaws.com/qc/gcr-sol-qc-$ReleaseVersion.yaml"

fi

echo ""
echo "https://aws-gcr-rs-sol-workshop-ap-northeast-1-common.s3.ap-northeast-1.amazonaws.com/qc/gcr-sol-qc.yaml"
echo ""