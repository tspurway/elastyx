job_id=$(python2 -m mrjob.tools.emr.create_job_flow -c mrjob.conf)

step_num=1

python2 elastyx.py \
    -c mrjob.conf \
    -r emr \
    --no-bootstrap-mrjob \
    --hadoop-arg -libjars \
    --hadoop-arg /home/hadoop/build/elastyxOutput.jar,/home/hadoop/build/org.json.jar \
    --no-output \
    --output-dir s3://tiles-elastyx-stage-1/output/$step_num/ \
    s3://tiles-elastyx-stage-1/input/sample1 \
    --emr-job-flow-id $job_id


