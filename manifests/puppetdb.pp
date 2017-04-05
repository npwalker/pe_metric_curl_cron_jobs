class pe_metric_curl_cron_jobs::puppetdb (
  Integer       $collection_frequency = $::pe_metric_curl_cron_jobs::collection_frequency,
  Integer       $retention_days       = $::pe_metric_curl_cron_jobs::retention_days,
  String        $metrics_ensure       = $::pe_metric_curl_cron_jobs::puppetdb_metrics_ensure,
  Array[String] $hosts                = $::pe_metric_curl_cron_jobs::puppetdb_hosts,
  Integer       $port                 = $::pe_metric_curl_cron_jobs::puppetdb_port,
) {
  Pe_metric_curl_cron_jobs::Pe_metric {
    output_dir     => $::pe_metric_curl_cron_jobs::output_dir,
    scripts_dir    => $::pe_metric_curl_cron_jobs::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  $activemq_metrics = [
    { 'name' => 'amq_metrics',
      'url'  => 'org.apache.activemq:type=Broker,brokerName=localhost,destinationType=Queue,destinationName=puppetlabs.puppetdb.commands' }
  ]

  $base_metrics = [
    { 'name' => 'command_processing_time',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.processing-time' },
    { 'name' => 'command_processed',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.processed' },
    { 'name' => 'catalog_hash_miss',
      'url'  => 'puppetlabs.puppetdb.storage%3Aname%3Dcatalog-hash-miss-time' },
    { 'name' => 'catalog_hash_match',
      'url'  => 'puppetlabs.puppetdb.storage%3Aname%3Dcatalog-hash-match-time' },
    { 'name' => 'replace_catalog_time',
      'url'  => 'puppetlabs.puppetdb.storage%3Aname%3Dreplace-catalog-time' },
    { 'name' => 'replace_facts_time',
      'url'  => 'puppetlabs.puppetdb.storage%3Aname%3Dreplace-facts-time' },
    { 'name' => 'store_report_time',
      'url'  => 'puppetlabs.puppetdb.storage%3Aname%3Dstore-report-time' },
    { 'name' => 'global_retried',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dglobal.retried' },
    { 'name' => 'global_retry_counts',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dglobal.retry-counts' },
  ]

  $numbers = $::pe_server_version ? {
    /^2015.2/     => {'catalogs' => 6, 'facts' => 4, 'reports' => 6},
    /^2015.3/     => {'catalogs' => 7, 'facts' => 4, 'reports' => 6},
    /^2016.(1|2)/ => {'catalogs' => 8, 'facts' => 4, 'reports' => 7},
    /^2016.(4|5)/ => {'catalogs' => 9, 'facts' => 5, 'reports' => 8},
    /^2017.(1|2)/ => {'catalogs' => 9, 'facts' => 5, 'reports' => 8},
    default       => {'catalogs' => 9, 'facts' => 5, 'reports' => 8},
  }

  $version_specific_metrics = [
    { 'name' => 'replace_catalog_retried',
      'url'  => "puppetlabs.puppetdb.mq%3Aname%3Dreplace+catalog.${numbers['catalogs']}.retried" },
    { 'name' => 'replace_catalog_retry_counts',
      'url'  => "puppetlabs.puppetdb.mq%3Aname%3Dreplace+catalog.${numbers['catalogs']}.retry-counts" },
    { 'name' => 'replace_facts_retried',
      'url'  => "puppetlabs.puppetdb.mq%3Aname%3Dreplace+facts.${numbers['facts']}.retried" },
    { 'name' => 'replace_facts_retry_counts',
      'url'  => "puppetlabs.puppetdb.mq%3Aname%3Dreplace+facts.${numbers['facts']}.retry-counts" },
    { 'name' => 'store_report_retried',
      'url'  => "puppetlabs.puppetdb.mq%3Aname%3Dstore+report.${numbers['reports']}.retried" },
    { 'name' => 'store_reports_retry_counts',
      'url'  => "puppetlabs.puppetdb.mq%3Aname%3Dstore+report.${numbers['reports']}.retry-counts" },
  ]

  $additional_metrics = versioncmp($::pe_server_version, '2017.1.0') ? {
    -1      => $activemq_metrics + $base_metrics + $version_specific_metrics,
    default => $base_metrics + $version_specific_metrics,
  }

  pe_metric_curl_cron_jobs::pe_metric { 'puppetdb' :
    metric_ensure => $metrics_ensure,
    hosts         => $hosts,
    metrics_port  => $port,
    additional_metrics => $additional_metrics,
  }
}
