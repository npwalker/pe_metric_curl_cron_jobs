class pe_metric_curl_cron_jobs (
  String        $output_dir                   = '/opt/puppetlabs/pe_metric_curl_cron_jobs',
  String        $puppetserver_metrics_ensure  = 'present',
  Array[String] $puppetserver_hosts           = [ '127.0.0.1' ],
  String        $puppetdb_metrics_ensure      = 'present',
  Array[String] $puppetdb_hosts               = [ '127.0.0.1' ],
) {

  $scripts_dir = "${output_dir}/scripts"

  file { [ $output_dir, $scripts_dir ] :
    ensure => directory,
  }

  Pe_metric_curl_cron_jobs::Pe_metric {
    output_dir  => $output_dir,
    scripts_dir => $scripts_dir,
  }

  pe_metric_curl_cron_jobs::pe_metric { 'puppetserver' :
    metric_ensure => $puppetserver_metrics_ensure,
    hosts         => $puppetserver_hosts,
  }

  $pdb_metrics_base = [
    { 'name' => 'commands_queue',
      'url'  => 'org.apache.activemq:type=Broker,brokerName=localhost,destinationType=Queue,destinationName=puppetlabs.puppetdb.commands' },
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
    { 'name' => 'global_retry_persistence_time',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dglobal.retry-persistence-time' },
  ]

  $pdb_metrics_20164 = [
    { 'name' => 'replace_catalog_retried',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dreplace+catalog.9.retried' },
    { 'name' => 'replace_catalog_retry_counts',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dreplace+catalog.9.retry-counts' },
    { 'name' => 'replace_catalog_retry_persistence_time',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dreplace+catalog.9.retry-persistence-time' },
    { 'name' => 'replace_facts_retried',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dreplace+facts.5.retried' },
    { 'name' => 'replace_facts_retry_counts',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dreplace+facts.5.retry-counts' },
    { 'name' => 'replace_facts_retry_persistence_time',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dreplace+facts.5.retry-persistence-time' },
    { 'name' => 'store_report_retried',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dstore+report.8.retried' },
    { 'name' => 'store_reports_retry_counts',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dstore+report.8.retry-counts' },
    { 'name' => 'store_report_retry_persistence_time',
      'url'  => 'puppetlabs.puppetdb.mq%3Aname%3Dstore+report.8.retry-persistence-time' },
  ]

  $pdb_metrics_array = $::pe_server_version ? {
    /^2016.4./ => $pdb_metrics_base + $pdb_metrics_20164,
    default    => $pdb_metrics_base
  }

  pe_metric_curl_cron_jobs::pe_metric { 'puppetdb' :
    metric_ensure => $puppetdb_metrics_ensure,
    hosts         => $puppetdb_hosts,
    data          => $pdb_metrics_array,
  }

}
