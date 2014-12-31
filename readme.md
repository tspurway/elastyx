Overview
===

This is an EMR targeted clone of tspurway/infernyx

Notes
===

create default emr roles with the aws cli

jar files are deployed onto hadoop clusters straight out of github

it basically works, I just need to get my last bits in order:

* sqs
* redshift
* actually use a geoip database
* insert the real `locale_whitelist`
* deploying jars from local dir or s3 instead of github
* determine permissions required to run emr jobs

Known bugs:

* mrjob 0.4.2 (current stable), does not work with STS credentials, because it does not set `ServiceRole` and `JobFlowRole` in the `run_jobflow` boto call. These api params can be set in mrjob 0.4.3-dev, but other things are broken in that version of mrjob.
    * Fix: overrode internal bits to set api params
