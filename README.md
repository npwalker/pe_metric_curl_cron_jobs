Table of Contents
=================

  * [How to use](#how-to-use)
    * [Monolithic Install](#monolithic-install)
    * [Split Install ( Running on the Master )](#split-install--running-on-the-master-)
    * [Monolithic With Compile Masters ( Running on the MoM )](#monolithic-with-compile-masters--running-on-the-mom-)
    * [Split With Compile Masters ( Running on the MoM )](#split-with-compile-masters--running-on-the-mom-)
    * [Running on PE 3\.8](#running-on-pe-38)
    * [Other Option](#other-option)
  * [What do you get](#what-do-you-get)
    * [Grepping for Metrics](#grepping-for-metrics)
      * [Puppetserver](#puppetserver)
      * [PuppetDB](#puppetdb)

# How to use

```
include pe_metric_curl_cron_jobs
```

If you do not want to manage this long term and want to get it up and running quickly you can run it via puppet apply.

## Monolithic Install

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "class { 'pe_metric_curl_cron_jobs': }" --modulepath .
```

## Split Install ( Running on the Master )

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "class { 'pe_metric_curl_cron_jobs' : puppetdb_hosts => ['split-puppetdb.domain.com'] }" --modulepath .
```

## Monolithic With Compile Masters ( Running on the MoM )

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "class { 'pe_metric_curl_cron_jobs' : puppet_server_hosts => ['compile-master-1.domain.com', 'compile-master-2.domain.com'] }" --modulepath .
```

## Split With Compile Masters ( Running on the MoM )

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "class { 'pe_metric_curl_cron_jobs' : puppetdb_hosts => ['split-puppetdb.domain.com'], puppet_server_hosts => ['compile-master-1.domain.com', 'compile-master-2.domain.com'] }" --modulepath .
```

## Running on PE 3.8

You can still use this module on PE 3.8 although you have to run it with the future parser and you want to use `/opt/puppet` instead of `/opt/puppetlabs`.

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "class { 'pe_metric_curl_cron_jobs' : output_dir => '/opt/puppet/pe_metric_curl_cron_jobs' }"  --modulepath . --parser=future
```

Refer to the other examples if you want to change other parameters.

## Other Option

This option puts metrics on each individual node so I don't think it's as good as having centrally gathered metrics but you can also install the module on each individual node.  If you install on a compile master you can set `puppetdb_metrics_ensure` to `absent` and if you install on a puppetdb node then you can set `$puppet_server_metrics_ensure` to `absent`.

# What do you get

By default the module tracks the metrics coming from the status endpoint on Puppetserver and the internal ActiveMQ metrics on PuppetDB.  

A new directory `/opt/puppetlabs/pe_metric_curl_cron_jobs` that looks like:

```
/opt/puppetlabs/pe_metric_curl_cron_jobs/
├── puppetdb
│   ├── 127.0.0.1-08_16_16_23:40.json
│   └── 127.0.0.1-08_16_16_23:45.json
│   └── 127.0.0.1-08_16_16_23:50.json
├── puppet_server
│   ├── 127.0.0.1-08_16_16_23:40.json
│   ├── 127.0.0.1-08_16_16_23:45.json
│   ├── 127.0.0.1-08_16_16_23:50.json
└── scripts
    ├── puppetdb_metrics.sh
    └── puppet_server_metrics.sh
```

New cronjobs:

```
crontab -l
...
# Puppet Name: puppet_server_metrics_collection
*/5 * * * * /opt/puppetlabs/pe_metric_curl_cron_jobs/scripts/puppet_server_metrics.sh
# Puppet Name: puppet_server_metrics_tidy
* 2 * * * puppet apply -e " tidy { '/opt/puppetlabs/pe_metric_curl_cron_jobs/puppet_server' : age => '3d', recurse => 1 } "
# Puppet Name: puppetdb_metrics_collection
*/5 * * * * /opt/puppetlabs/pe_metric_curl_cron_jobs/scripts/puppetdb_metrics.sh
# Puppet Name: puppetdb_metrics_tidy
* 2 * * * puppet apply -e " tidy { '/opt/puppetlabs/pe_metric_curl_cron_jobs/puppetdb' : age => '3d', recurse => 1 } "
```

## Grepping for Metrics

You can get useful information with a grep like the one below run from inside of the directory containing the metrics files.

```
grep <metric_name> 127.0.0.1-*
```

### Puppetserver

Example output:

```
grep average-free-jrubies 127.0.0.1-*
127.0.0.1-08_15_16_10:55.json:                    "average-free-jrubies": 3.6687597774999556,
127.0.0.1-08_15_16_11:00.json:                    "average-free-jrubies": 4.4209186472147248,
127.0.0.1-08_15_16_11:05.json:                    "average-free-jrubies": 3.610399319630555,
127.0.0.1-08_15_16_11:10.json:                    "average-free-jrubies": 4.9845629308522383,
```

### PuppetDB

Example output:

```
grep QueueSize 127.0.0.1-*
127.0.0.1-08_16_16_23:40.json:  "QueueSize" : 0,
127.0.0.1-08_16_16_23:45.json:  "QueueSize" : 0,
```

```
grep CursorMemoryUsage 127.0.0.1-*
127.0.0.1-08_16_16_23:40.json:  "CursorMemoryUsage" : 0,
127.0.0.1-08_16_16_23:45.json:  "CursorMemoryUsage" : 0,
```

```
grep CursorFull 127.0.0.1-*
127.0.0.1-08_16_16_23:40.json:  "CursorFull" : false,
127.0.0.1-08_16_16_23:45.json:  "CursorFull" : false,
```

```
grep CursorPercentUsage 127.0.0.1-*
127.0.0.1-08_16_16_23:40.json:  "CursorPercentUsage" : 0,
127.0.0.1-08_16_16_23:45.json:  "CursorPercentUsage" : 0,
```
