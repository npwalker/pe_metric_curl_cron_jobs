Table of Contents
=================

* [What do you get](#what-do-you-get)
  * [Directory layout](#directory-layout)
  * [Cron jobs](#cron-jobs)
  * [Grepping for Metrics](#grepping-for-metrics)
    * [Puppetserver](#puppetserver)
    * [PuppetDB](#puppetdb)
  * [Sharing Metrics data](#sharing-metrics-data)
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

# What do you get

By default, the module tracks the metrics coming from the status endpoint on Puppet Server and PuppetDB as well as a curated set of metrics from PuppetDB.

## Directory layout

You have a new directory `/opt/puppetlabs/puppet_metrics_collector` that has one directory per component  (Puppet Server, PuppetDB, or ActiveMQ).  Each component has one directory per host that metrics are gathered from.  Each host directory contains one JSON file collected every 5 minutes by default.  Once per day the metrics for each component are compressed for every host and saved in the root of that component's directory.

Here's an example:

~~~
/opt/puppetlabs/puppet_metrics_collector/puppetserver
├── 127.0.0.1
│   ├── 20170404T020001Z.json
│   ├── ...
│   ├── 20170404T170501Z.json
│   └── 20170404T171001Z.json
└── puppetserver-2017.04.04.02.00.01.tar.bz2
/opt/puppetlabs/puppet_metrics_collector/puppetdb
└── 127.0.0.1
│   ├── 20170404T020001Z.json
│   ├── ...
│   ├── 20170404T170501Z.json
│   ├── 20170404T171001Z.json
└── puppetdb-2017.04.04.02.00.01.tar.bz2
~~~

## Cron jobs

Each component has two cron jobs created for it.

- A cron job to gather the metrics
  - Runs every 5 minutes
- A cron job to delete metrics past the rentention_days and compress metrics
  - Runs at randomly selected time between midnight and 3AM

Example:

~~~
crontab -l
...
# Puppet Name: puppetserver_metrics_collection
*/5 * * * * /opt/puppetlabs/puppet_metrics_collector/scripts/puppetserver_metrics
# Puppet Name: puppetserver_metrics_tidy
0 2 * * * /opt/puppetlabs/puppet_metrics_collector/scripts/puppetserver_metrics_tidy
~~~

## Grepping for Metrics

You can get useful information with a grep like the one below run from inside of the directory containing the metrics files.  Since the metrics are compressed every night you can only grep metrics for the current day.  If you'd like to grep over a longer period of time you should decompress the compressed tarballs into `/tmp` and investigate further.

~~~
cd /opt/puppetlabs/puppet_metrics_collector
grep <metric_name> <component_name>/127.0.0.1/*.json
~~~

### Puppetserver

Example output:

~~~
grep average-free-jrubies puppetserver/127.0.0.1/*.json
puppetserver/127.0.0.1/20170404T170501Z.json:                "average-free-jrubies": 0.9950009285369501,
puppetserver/127.0.0.1/20170404T171001Z.json:                "average-free-jrubies": 0.9999444653324225,
puppetserver/127.0.0.1/20170404T171502Z.json:                "average-free-jrubies": 0.9999993830655706,
~~~

### PuppetDB

Example output:

~~~
grep queue_depth puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170404T170501Z.json:            "queue_depth": 0,
puppetdb/127.0.0.1/20170404T171001Z.json:            "queue_depth": 0,
puppetdb/127.0.0.1/20170404T171502Z.json:            "queue_depth": 0,
~~~

PE 2016.5 and below:

```
grep Cursor puppetdb/127.0.0.1/*.json
puppetdb/127.0.0.1/20170404T171001Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170404T171001Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170404T171001Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170404T171502Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170404T171502Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170404T171502Z.json:          "CursorPercentUsage": 0,
puppetdb/127.0.0.1/20170404T172002Z.json:          "CursorMemoryUsage": 0,
puppetdb/127.0.0.1/20170404T172002Z.json:          "CursorFull": false,
puppetdb/127.0.0.1/20170404T172002Z.json:          "CursorPercentUsage": 0,
```

## Sharing Metrics data

When working on performance tuning you may be asked to create a metrics data tarball to transport and share your metrics data.

The module provides a utility script, `puppet-metrics-collector` to aid in preparing metrics data for transport.

```
[root@master ~]# /opt/puppetlabs/bin/puppet-metrics-collector create-tarball
Metrics data tarball created at: /root/puppet-metrics-20170801T180338Z.tar.gz
```

The script creates a tarball containing your metrics in the current working directory.dd

# How to use

Install the module with `puppet module install npwalker-puppet_metrics_collector` or add it to your Puppetfile.

To start data collection you will need to classify your puppet master with the `puppet_metrics_collector` class using your preferred classification method.

The following examples show how to configure the parameters to work in different setups but we assume you will always classify on the node that is the CA master.  The preferred method is to `include` the module and then provide hiera
data for the parameters.

## Monolithic Install

### Hiera data Example

None needed for a monolithic install

### Class Definition

~~~
include puppet_metrics_collector
~~~

## Split Install ( Running on the Master )

### Hiera data Example

~~~
puppet_metrics_collector::puppetdb_hosts:
 - 'split-puppetdb.domain.com'
~~~

### Class Definition Example

~~~
class { 'puppet_metrics_collector':
  puppetdb_hosts => ['split-puppetdb.domain.com']
}
~~~

## Monolithic With Compile Masters ( Running on the MoM )

### Hiera data Example

~~~
puppet_metrics_collector::puppetserver_hosts:
 - 'master-1.domain.com'
 - 'compile-master-1.domain.com'
 - 'compile-master-2.domain.com'
~~~

### Class Definition Example

~~~
class { 'puppet_metrics_collector':
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
puppet_metrics_collector::puppetdb_hosts:
 - 'split-puppetdb.domain.com'
puppet_metrics_collector::puppetserver_hosts:
 - 'master-1.domain.com'
 - 'compile-master-1.domain.com'
 - 'compile-master-2.domain.com'
~~~

### Class Definition Example

~~~
class { 'puppet_metrics_collector':
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
class { 'puppet_metrics_collector':
  output_dir => '/opt/puppet/puppet_metrics_collector'
}
~~~

The module can be run in a one off run if the future parser is not enabled in the environment.

~~~
puppet module install npwalker-puppet_metrics_collector --modulepath /tmp;
puppet apply -e "class { 'puppet_metrics_collector' : output_dir => '/opt/puppet/puppet_metrics_collector' }"  --modulepath /tmp --parser=future
~~~

If you do not want to manage this long term and want to get it up and running quickly you can run it via puppet apply. Make sure the puppetlabs-stdlib module is installed. Refer to the other examples if you want to change other parameters.

## Temporary Install

The module installation is the best way to utilize this module, but it can be run on a one off basis with the following command.

~~~
puppet module install npwalker-puppet_metrics_collector --modulepath /tmp;
puppet apply -e "class { 'puppet_metrics_collector': }" --modulepath /tmp;
~~~

## Alternate Option for Multi-node Metrics Collection

This option puts metrics on each individual node instead of gathering metrics centrally on the CA master.  In order to do so, you would classify each of your PE infrastructure nodes with this module.  This option is discouraged but if
for some reason you can't reach out across a network segment or some other reason you may still wish to have metrics.

When you classify a compile master you would set `$puppetdb_metrics_ensure` to `absent`.

When you classify a PuppetDB node you would set `$puppetserver_metrics_ensure` to `absent`.
