Table of Contents
=================

* [Table of Contents](#table-of-contents)
* [How to use](#how-to-use)
	 * [Monolithic Intall](#monolithic-intall)
	 * [Split Install ( Running on the Master )](#split-install--running-on-the-master-)
	 * [Monolithic With Compile Masters ( Running on the MoM )](#monolithic-with-compile-masters--running-on-the-mom-)
	 * [Split With Compile Masters ( Running on the MoM )](#split-with-compile-masters--running-on-the-mom-)
	 * [Running on PE 3.8](#running-on-pe-38)
	 * [Temporary Install](#temporary-install)
	 * [Other Option for Split Install](#other-option-for-split-install)
* [What do you get](#what-do-you-get)
  * [Grepping for Metrics](#grepping-for-metrics)
    * [Puppetserver](#puppetserver)
    * [PuppetDB](#puppetdb)

# How to use

Install the module with `puppet module install npwalker-pe_metric_curl_cron_jobs`.

## Monolithic Intall
To start data collection on a monolithic installation add the following to the Puppet master's node definition in the *site.pp* or add the `pe_metric_curl_cron_jobs` class in the node classifier.

```
  include pe_metric_curl_cron_jobs
```

## Split Install ( Running on the Master )
To start data collection on a split installation add the following to the Puppet master's node definition in the *site.pp* or add the `pe_metric_curl_cron_jobs` class in the node classifier.

```
class { 'pe_metric_curl_cron_jobs':
  puppetdb_hosts => ['split-puppetdb.domain.com']
}

```

## Monolithic With Compile Masters ( Running on the MoM )
To start data collection on a monolithic installation with compile masters add the following to the Puppet master's node definition in the *site.pp* or add the `pe_metric_curl_cron_jobs` class in the node classifier.

```
class { 'pe_metric_curl_cron_jobs':
  puppet_server_hosts => [
    'master-1.domain.com',
    'compile-master-1.domain.com',
    'compile-master-2.domain.com'
  ]
}
```

## Split With Compile Masters ( Running on the MoM )
To start data collection on a split installation with compile masters add the following to the Puppet master's node definition in the *site.pp* or add the `pe_metric_curl_cron_jobs` class in the node classifier.

```
class { 'pe_metric_curl_cron_jobs':
  puppetdb_hosts => ['split-puppetdb.domain.com'],
  puppet_server_hosts => [
    'master-1.domain.com',
    'compile-master-1.domain.com',
    'compile-master-2.domain.com'
  ]
}
```

## Running on PE 3.8

You can still use this module on PE 3.8 although you have to run it with the future parser and you want to use `/opt/puppet` instead of `/opt/puppetlabs`. If the [future parser](https://docs.puppet.com/puppet/3.8/experiments_future.html) is enabled in the environment or globally, the following can be put in the site.pp.

```
class { 'pe_metric_curl_cron_jobs':
  output_dir => '/opt/puppet/pe_metric_curl_cron_jobs'
}
```

The module can be run in a one off run if the future parser is not enabled in the environment.

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "class { 'pe_metric_curl_cron_jobs' : output_dir => '/opt/puppet/pe_metric_curl_cron_jobs' }"  --modulepath ".:$(puppet config print modulepath)" --parser=future
```

If you do not want to manage this long term and want to get it up and running quickly you can run it via puppet apply. Make sure the puppetlabs-stdlib module is installed. Refer to the other examples if you want to change other parameters.

## Temporary Install

The module installation is the best way to utilize this module, but it can be run on a one off basis with the following command.

```
cd /tmp;
git clone https://github.com/npwalker/pe_metric_curl_cron_jobs;
puppet apply -e "class { 'pe_metric_curl_cron_jobs': }" --modulepath ".:$(puppet config print modulepath)"
```

## Other Option for Split Install

This option puts metrics on each individual node so I don't think it's as good as having centrally gathered metrics, but you can also install the module on each individual node.  If you install on a compile master you can set `puppetdb_metrics_ensure` to `absent` and if you install on a puppetdb node then you can set `$puppet_server_metrics_ensure` to `absent`.

# What do you get

By default the module tracks the metrics coming from the status endpoint on Puppetserver and the internal ActiveMQ metrics on PuppetDB.

A new directory `/opt/puppetlabs/pe_metric_curl_cron_jobs` that looks like:

```
/opt/puppetlabs/pe_metric_curl_cron_jobs/
├── puppetdb
│   └── 127.0.0.1
│       ├── 20170314T205501Z.json
│       ├── 20170314T205510Z.json
│       └── 20170314T210001Z.json
├── puppetserver
│   └── 127.0.0.1
│       ├── 20170314T205001Z.json
│       ├── 20170314T205501Z.json
│       └── 20170314T210001Z.json
└── scripts
    ├── puppetdb_metrics
    └── puppetserver_metrics
```

New cronjobs:

```
crontab -l
...
# Puppet Name: puppetserver_metrics_collection
*/5 * * * * /opt/puppetlabs/pe_metric_curl_cron_jobs/scripts/puppetserver_metrics
# Puppet Name: puppetserver_metrics_tidy
* 2 * * * find '/opt/puppetlabs/pe_metric_curl_cron_jobs' -type f -mtime 3 -delete
# Puppet Name: puppetdb_metrics_collection
*/5 * * * * /opt/puppetlabs/pe_metric_curl_cron_jobs/scripts/puppetdb_metrics
# Puppet Name: puppetdb_metrics_tidy
* 2 * * * find '/opt/puppetlabs/pe_metric_curl_cron_jobs' -type f -mtime 3 -delete
```

## Grepping for Metrics

You can get useful information with a grep like the one below run from inside of the directory containing the metrics files.

```
grep <metric_name> ./127.0.0.1/*.json
```

### Puppetserver

Example output:

```
grep average-free-jrubies puppetserver/127.0.0.1/*.json
puppetserver/127.0.0.1/20170314T204501Z.json:                "average-free-jrubies": 0.9999535595280031,
puppetserver/127.0.0.1/20170314T205001Z.json:                "average-free-jrubies": 0.995494318690345,
puppetserver/127.0.0.1/20170314T205501Z.json:                "average-free-jrubies": 0.8035181730040821,
puppetserver/127.0.0.1/20170314T210001Z.json:                "average-free-jrubies": 0.9978172841156308,
```

### PuppetDB

Example output:

```
grep QueueSize puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "QueueSize": 0,
puppetdb/127.0.0.1/20170314T205510Z.json:          "QueueSize": 0,
puppetdb/127.0.0.1/20170314T210001Z.json:          "QueueSize": 0,
```

```
grep CursorMemoryUsage puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170314T205510Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170314T210001Z.json:          "CursorMemoryUsage": 0,
```

```
grep CursorFull puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170314T205510Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170314T210001Z.json:          "CursorFull": false,
```

```
grep CursorPercentUsage puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170314T205510Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170314T210001Z.json:          "CursorPercentUsage": 0,
```
