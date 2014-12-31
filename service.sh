#!/bin/bash

BUCKET="${BUCKET:-elastyx}"
QUEUE_URL="${SQS_QUEUE:-elastyx}"
REDSHIFT_ENDPOINT="${SQS_QUEUE:-redshift}"

# create emr job flow
job_flow_id=''

# catch exit and terminate job flow

while true; do
    # list logs from sqs
    logs=''
    sqs_handles=''
    while true; do
        # receieve sqs messages
        received_messages="$(
            aws sqs receive-message \
                --queue-url "$QUEUE_URL" \
                --max-number-of-messages 10 \
                --visibility-timeout 600 \
                --wait-time-seconds 0
        )"

        if [ -z "$received_messages" ]; then
            break
        fi

        # extract s3 log paths from messages
        logs+="
        $(
            echo "$received_messages" |
                jq -r '.Messages[].Body
                    | fromjson
                    | select(.label == "impression")
                    | "s3://" + .bucket + "/" + .path'
        )"
        # extract message delete info from messages
        sqs_handles+="
        $(
            echo "$received_messages" | jq -r .Messages[].ReceiptHandle
        )"
    done

    # run a step on the job flow with logs read from sqs
    /usr/local/bin/elastyx.py \
        -r emr \
        --no-bootstrap-mrjob \
        --hadoop-arg -libjars \
        --hadoop-arg /home/hadoop/elastyxOutput.jar,/home/hadoop/org.json.jar \
        --s3-log-uri s3://$BUCKET/log/ \
        --s3-scratch-uri s3://$BUCKET/tmp/ \
        --no-output \
        $logs

    # copy output to redshift

    # delete logs from sqs
    echo "$sqs_handles" | xargs -n1 aws sqs delete-message --queue-url "$QUEUE_URL" --receipt-handle
done
