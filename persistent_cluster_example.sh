job_id=$(python2 -m mrjob.tools.emr.create_job_flow -c mrjob.conf)

step_num=1

python2 elastyx.py \
    -c mrjob.conf \
    -r emr \
    --no-bootstrap-mrjob \
    --hadoop-arg -libjars \
    --hadoop-arg /home/hadoop/elastyxOutput.jar,/home/hadoop/org.json.jar \
    --no-output \
    --output-dir s3://tiles-stage-1-queue-s3-bucket-abcdef/elastyx/$step_num/ \
    s3://tiles-stage-1-queue-s3-bucket-abcdefg/impression/2099-12-31/zyxwvut \
    --emr-job-flow-id $job_id


