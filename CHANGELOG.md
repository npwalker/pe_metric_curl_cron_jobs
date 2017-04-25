# Minor Release 4.2.0

## Improvements
 - Add a `--no-file` command line argument to the metrics scripts
   - This allows for integrations to optionally not write metrics to a file
   - [PR #27](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/27)

# Minor Release 4.1.0

## Improvements
 - Retrieve all additional metrics with one POST instead of multiple GETs
   - [PR #23](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/23)
 - Add a `--print` command line argument to the metrics scripts
   - This allows for integrations with other tools that can read the output from stdout.
   - [PR #24](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/24)
 - Move script configuration into a YAML file
   - Allow the metrics scripts to be stored as static files instead of templates
   - [PR #25](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/25)

# Major Release 4.0.0

This is a major release because some of the PuppetDB metrics are renamed.
For most users this update is only additive, however, if you are post processing
the output of the module then you may need to update to the new names of the metrics.

## Changes
 - Rename some PuppetDB metrics
   - command_processing_time is now global_processing_time
   - command_processed is now global_processed
   - replace_catalog_time is now storage_replace-catalog-time
   - replace_facts_time is now storage_replace-facts-time
   - store_report_time is now storage_store-report-time
   - *\_retry and *\_retry-counts metrics are renamed to include mq\_ at the front

## Improvements
 - We now collect the output of the status endpoint for orchestrator
 - We now collect HakariCP connection pooling metrics for PuppetDB
 - We now collect the global metrics for PuppetDB
 - We now collect the storage metrics for PuppetDB
 - Each component now has its own class to allow customizing parameters per
  component

# Z Release 3.0.1

## Bug Fixes:
 - Stagger compression of files between midnight and 3AM to prevent a CPU spike
   - [PR #22](https://github.com/npwalker/pe_metric_curl_cron_jobs/pull/22)

# Major Release 3.0.0

## Changes
 - Every parameter, file name, etc... that contained puppet_server is rewritten
 to puppetserver
   - The existing parameters remain but are deprecated and should not be used
 - Metric storage format is a single JSON blob instead of the exact output from
 whichever endpoint was queried

## Improvements
 - Metrics gathering scripts are rewritten in ruby
 - Metrics are now stored in one file per component
   - PuppetDB metrics were previously stored with one file per metric
   - Metrics are now stored in one directory per server
 - PuppetDB metrics now gathers the status endpoint
   - This is the preferred way to get the queue_depth metric
 - Opt-in collection of ActiveMQ metrics is available
 - Metrics are compressed daily for a 90% reduction in disk space
   - Metrics are retained for 90 days by default instead of 3 days
     - Retained metrics still take less space due to compression savings

## Bug Fixes:
 - The metrics tidy cron job previously ran every minute between 2-3 AM.
It now runs just once at 2AM.
