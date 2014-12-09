BEGIN;

COPY impression_stats_daily
    FROM 's3://tiles-elastyx-stage-1/output/1/impression_stats/'
    CREDENTIALS 'aws_access_key_id=<access-key-id>;aws_secret_access_key=<secret-access-key>;token=<token>'
    JSON 'auto';

COPY newtab_stats_daily
    FROM 's3://tiles-elastyx-stage-1/output/1/newtab_stats/'
    CREDENTIALS 'aws_access_key_id=<access-key-id>;aws_secret_access_key=<secret-access-key>;token=<token>'
    JSON 'auto';

COMMIT;
