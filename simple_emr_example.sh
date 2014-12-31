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
    s3://$bucket/impression/
