
rm -rf braket_install/ > /dev/null 2>&1

mkdir braket_install/ && cd braket_install/
aws s3 cp s3://braketnotebookcdk-notebooklccs3bucketb3089b50-1w1epzvg1km1k/notebook/braket-notebook-lcc.zip .
unzip braket-notebook-lcc.zip
rm braket-notebook-lcc.zip

docker build -t qc-batch-experiment .
