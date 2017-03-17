Table of Contents
=================

  * [How to use](#how-to-use)
    * [Monolithic Install](#monolithic-install)
      * [Hiera data Example](#hiera-data-example)
      * [Class Definition](#class-definition)
    * [Split Install ( Running on the Master )](#split-install--running-on-the-master-)
      * [Hiera data Example](#hiera-data-example-1)
      * [Class Definition Example](#class-definition-example)
    * [Monolithic With Compile Masters ( Running on the MoM )](#monolithic-with-compile-masters--running-on-the-mom-)
      * [Hiera data Example](#hiera-data-example-2)
      * [Class Definition Example](#class-definition-example-1)
    * [Split With Compile Masters ( Running on the MoM )](#split-with-compile-masters--running-on-the-mom-)
      * [Hiera data Example](#hiera-data-example-3)
      * [Class Definition Example](#class-definition-example-2)
    * [Running on PE 3\.8](#running-on-pe-38)
    * [Temporary Install](#temporary-install)
    * [Alternate Option for Multi\-node Metrics Collection](#alternate-option-for-multi-node-metrics-collection)
  * [What do you get](#what-do-you-get)
    * [Grepping for Metrics](#grepping-for-metrics)
      * [Puppetserver](#puppetserver)
      * [PuppetDB](#puppetdb)

# How to use

Install the module with `puppet module install npwalker-pe_metric_curl_cron_jobs` or add it to your Puppetfile.

To start data collection you will need to classify your puppet master with the `pe_metric_curl_cron_jobs` class using your preferred classification method.

The following examples show how to configure the parameters to work in different setups but we assume you will always classify on the node that is the CA master.  The preferred method is to `include` the module and then provide hiera
data for the parameters.

## Monolithic Install

### Hiera data Example

None needed for a monolithic install

### Class Definition

~~~
include pe_metric_curl_cron_jobs
~~~

## Split Install ( Running on the Master )

### Hiera data Example

~~~
pe_metric_curl_cron_jobs::puppetdb_hosts:
 - 'split-puppetdb.domain.com'
~~~

### Class Definition Example

~~~
class { 'pe_metric_curl_cron_jobs':
  puppetdb_hosts => ['split-puppetdb.domain.com']
}
~~~

## Monolithic With Compile Masters ( Running on the MoM )

### Hiera data Example

~~~
pe_metric_curl_cron_jobs::puppetserver_hosts:
 - 'master-1.domain.com'
 - 'compile-master-1.domain.com'
 - 'compile-master-2.domain.com'
~~~

### Class Definition Example

~~~
class { 'pe_metric_curl_cron_jobs':
  puppetserver_hosts => [
    'master-1.domain.com',
    'compile-master-1.domain.com',
    'compile-master-2.domain.com'
  ]
}
~~~

## Split With Compile Masters ( Running on the MoM )

### Hiera data Example

~~~
pe_metric_curl_cron_jobs::puppetdb_hosts:
 - 'split-puppetdb.domain.com'
pe_metric_curl_cron_jobs::puppetserver_hosts:
 - 'master-1.domain.com'
 - 'compile-master-1.domain.com'
 - 'compile-master-2.domain.com'
~~~

### Class Definition Example

~~~
class { 'pe_metric_curl_cron_jobs':
  puppetdb_hosts => ['split-puppetdb.domain.com'],
  puppetserver_hosts => [
    'master-1.domain.com',
    'compile-master-1.domain.com',
    'compile-master-2.domain.com'
  ]
}
~~~

## Running on PE 3.8

You can still use this module on PE 3.8 although you have to run it with the future parser and you want to use `/opt/puppet` instead of `/opt/puppetlabs`. If the [future parser](https://docs.puppet.com/puppet/3.8/experiments_future.html) is enabled in the environment or globally, the following can be put in the site.pp.

~~~
class { 'pe_metric_curl_cron_jobs':
  output_dir => '/opt/puppet/pe_metric_curl_cron_jobs'
}
~~~

The module can be run in a one off run if the future parser is not enabled in the environment.

~~~
puppet module install npwalker-pe_metric_curl_cron_jobs --modulepath /tmp;
puppet apply -e "class { 'pe_metric_curl_cron_jobs' : output_dir => '/opt/puppet/pe_metric_curl_cron_jobs' }"  --modulepath /tmp --parser=future
~~~

If you do not want to manage this long term and want to get it up and running quickly you can run it via puppet apply. Make sure the puppetlabs-stdlib module is installed. Refer to the other examples if you want to change other parameters.

## Temporary Install

The module installation is the best way to utilize this module, but it can be run on a one off basis with the following command.

~~~
puppet module install npwalker-pe_metric_curl_cron_jobs --modulepath /tmp;
puppet apply -e "class { 'pe_metric_curl_cron_jobs': }" --modulepath /tmp;
~~~

## Alternate Option for Multi-node Metrics Collection

This option puts metrics on each individual node instead of gathering metrics centrally on the CA master.  In order to do so, you would classify each of your PE infrastructure nodes with this module.  This option is discouraged but if
for some reason you can't reach out across a network segment or some other reason you may still wish to have metrics.

When you classify a compile master you would set `$puppetdb_metrics_ensure` to `absent`.

When you classify a PuppetDB node you would set `$puppetserver_metrics_ensure` to `absent`.

# What do you get

By default the module tracks the metrics coming from the status endpoint on Puppetserver and various curated metrics from PuppetDB.

A new directory `/opt/puppetlabs/pe_metric_curl_cron_jobs` that looks like:

~~~
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
~~~

New cronjobs:

~~~
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
~~~

## Grepping for Metrics

You can get useful information with a grep like the one below run from inside of the directory containing the metrics files.

~~~
grep <metric_name> <service_name>/127.0.0.1/*.json
~~~

### Puppetserver

Example output:

~~~
grep average-free-jrubies puppetserver/127.0.0.1/*.json
puppetserver/127.0.0.1/20170314T204501Z.json:                "average-free-jrubies": 0.9999535595280031,
puppetserver/127.0.0.1/20170314T205001Z.json:                "average-free-jrubies": 0.995494318690345,
puppetserver/127.0.0.1/20170314T205501Z.json:                "average-free-jrubies": 0.8035181730040821,
puppetserver/127.0.0.1/20170314T210001Z.json:                "average-free-jrubies": 0.9978172841156308,
~~~

### PuppetDB

Example output:

~~~
grep QueueSize puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "QueueSize": 0,
puppetdb/127.0.0.1/20170314T205510Z.json:          "QueueSize": 0,
puppetdb/127.0.0.1/20170314T210001Z.json:          "QueueSize": 0,
~~~

~~~
grep CursorMemoryUsage puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170314T205510Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170314T210001Z.json:          "CursorMemoryUsage": 0,
~~~

~~~
grep CursorFull puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170314T205510Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170314T210001Z.json:          "CursorFull": false,
~~~

~~~
grep CursorPercentUsage puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170314T205501Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170314T205510Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170314T210001Z.json:          "CursorPercentUsage": 0,
~~~
