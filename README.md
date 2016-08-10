# How to use

```
include pe_metric_curl_cron_jobs
```

## What do you get

A new directory `/opt/puppetlabs/pe_metric_curl_cron_jobs` that looks like:

```
/opt/puppetlabs/pe_metric_curl_cron_jobs/
├── puppet_server
│   ├── localhost-08_10_16_21:50.json
│   ├── localhost-08_10_16_21:55.json
│   ├── localhost-08_10_16_22:00.json
│   └── localhost.json
└── scripts
    ├── puppetdb_metrics.sh
    └── puppet_server_metrics.sh
```

A new cronjob:

```
crontab -l | grep puppet_server
# Puppet Name: puppet_server_metrics_collection
*/5 * * * * /opt/puppetlabs/pe_metric_curl_cron_jobs/scripts/puppet_server_metrics.sh
```
