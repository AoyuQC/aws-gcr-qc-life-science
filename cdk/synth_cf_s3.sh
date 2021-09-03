#!/bin/bash 

cdk --profile rsops synth > gcr-sol-qc.yaml
aws --profile rsops s3 cp ./gcr-sol-qc.yaml s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/qc/ --acl public-read

echo 'https://aws-gcr-rs-sol-workshop-ap-northeast-1-common.s3.ap-northeast-1.amazonaws.com/qc/gcr-sol-qc.yaml'
