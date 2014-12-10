BEGIN;

COPY impression_stats_daily
    FROM 's3://tiles-stage-1-queue-s3-bucket-abcdef/elastyx/1/impression_stats/'
    CREDENTIALS 'aws_access_key_id=<access-key-id>;aws_secret_access_key=<secret-access-key>;token=<token>'
    JSON 'auto';

COPY newtab_stats_daily
    FROM 's3://tiles-stage-1-queue-s3-bucket-abcdef/elastyx/1/newtab_stats/'
    CREDENTIALS 'aws_access_key_id=<access-key-id>;aws_secret_access_key=<secret-access-key>;token=<token>'
    JSON 'auto';

COMMIT;
