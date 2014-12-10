job_id=$(python2 -m mrjob.tools.emr.create_job_flow -c mrjob.conf)

step_num=1

bucket=tiles-stage-1-queue-s3-bucket-abcdefghijkl

python2 elastyx.py \
    -c mrjob.conf \
    -r emr \
    --no-bootstrap-mrjob \
    --hadoop-arg -libjars \
    --hadoop-arg /home/hadoop/elastyxOutput.jar,/home/hadoop/org.json.jar \
    --s3-log-uri s3://$bucket/log/ \
    --s3-scratch-uri s3://$bucket/tmp/ \
    --no-output \
    --output-dir s3://$bucket/elastyx/$step_num/ \
    s3://$bucket/impression/ \
    --emr-job-flow-id $job_id
