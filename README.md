# How to use

```
include pe_metric_curl_cron_jobs
```

If you do not want to manage this long term and want to get it up and running quickly you can run it via puppet apply.

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "include pe_metric_curl_cron_jobs" --modulepath .
```

## What do you get

A new directory `/opt/puppetlabs/pe_metric_curl_cron_jobs` that looks like:

```
/opt/puppetlabs/pe_metric_curl_cron_jobs/
├── puppet_server
│   ├── localhost-08_10_16_21:50.json
│   ├── localhost-08_10_16_21:55.json
│   ├── localhost-08_10_16_22:00.json
└── scripts
    └── puppet_server_metrics.sh
```

A new cronjob:

```
crontab -l | grep puppet_server
# Puppet Name: puppet_server_metrics_collection
*/5 * * * * /opt/puppetlabs/pe_metric_curl_cron_jobs/scripts/puppet_server_metrics.sh
# Puppet Name: puppet_server_metrics_tidy
* 2 * * * puppet apply -e " tidy { '/opt/puppetlabs/pe_metric_curl_cron_jobs/puppet_server' : age => '3d', recurse => 1 } "
```

## Grepping for Metrics

You can get useful information with a grep like the one below run from inside of the directory containing the metrics files.

```
grep <metric_name> localhost-*
```

Example output:

```
grep average-free-jrubies localhost-*
localhost-08_15_16_10:55.json:                    "average-free-jrubies": 3.6687597774999556,
localhost-08_15_16_11:00.json:                    "average-free-jrubies": 4.4209186472147248,
localhost-08_15_16_11:05.json:                    "average-free-jrubies": 3.610399319630555,
localhost-08_15_16_11:10.json:                    "average-free-jrubies": 4.9845629308522383,
```
