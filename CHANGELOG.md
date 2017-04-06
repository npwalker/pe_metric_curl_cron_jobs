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
