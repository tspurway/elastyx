job_id=$(python2 -m mrjob.tools.emr.create_job_flow -c mrjob.conf)

python2 elastyx.py \
    -c mrjob.conf \
    -r emr \
    --no-output \
    --output-dir s3://tiles-elastyx-stage-1/output/ \
    s3://tiles-elastyx-stage-1/input/sample3 \
    --emr-job-flow-id $job_id


