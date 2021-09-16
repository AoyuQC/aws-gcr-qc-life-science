repo_name='qc-batch-experiment'
git pull && docker build -t $repo_name .
docker run -t  qc-batch-experiment --M 1