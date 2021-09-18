#!/bin/bash
#set -e

ReleaseVersion=$1

CURRDIR="$(pwd)/.."

echo $CURRDIR

if [[ $ReleaseVersion =~ v.* ]];then
    echo "ReleaseVersion: $ReleaseVersion"
else
    ReleaseVersion=''
fi


cd $CURRDIR/aws-gcr-qc-life-science/

if [[ -n $ReleaseVersion ]];then
  if git tag -a $ReleaseVersion -m "new release $ReleaseVersion"; then
        git push origin $ReleaseVersion
        echo ""
    else
       echo "tag $ReleaseVersion already exist, please remove it and try again"
       echo "    git tag -d $ReleaseVersion"
       echo "    git push origin :refs/tags/$ReleaseVersion"
       exit 1
  fi
fi


cp $CURRDIR/aws-gcr-qc-life-science/README.md  $CURRDIR/aws-gcr-qc-life-science-public/
cp $CURRDIR/aws-gcr-qc-life-science/performance.md  $CURRDIR/aws-gcr-qc-life-science-public/
cp -r $CURRDIR/aws-gcr-qc-life-science/protein  $CURRDIR/aws-gcr-qc-life-science-public/


cd $CURRDIR/aws-gcr-qc-life-science/cdk
./synth_cf_s3.sh $ReleaseVersion

cd $CURRDIR/aws-gcr-qc-life-science/protein/ligand-unfolding/batch-experiment/cf
./cf_to_s3.sh $ReleaseVersion

cd $CURRDIR/aws-gcr-qc-life-science-public/

pwd

git status
git add .
git commit -a -m 'new release'
git push

if [[ -n $ReleaseVersion ]];then
  if git tag -a $ReleaseVersion -m "new release $ReleaseVersion"; then
        git push origin $ReleaseVersion
        echo ""
    else
       echo "tag $ReleaseVersion already exist remove and re-tag"
       git tag -d $ReleaseVersion
       git push origin :refs/tags/$ReleaseVersion
       echo ""
       git tag -a $ReleaseVersion -m "new release $ReleaseVersion"
       git push origin $ReleaseVersion
       echo ""
  fi
fi


echo "Done"