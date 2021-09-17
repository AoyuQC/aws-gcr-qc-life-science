repo_name='qc-batch-experiment'
git pull && docker build -t $repo_name .

# docker run -t  qc-batch-experiment --M 1

docker run -t  qc-batch-experiment --M 1 \
--device-arn arn:aws:braket:::device/qpu/d-wave/DW_2000Q_6
