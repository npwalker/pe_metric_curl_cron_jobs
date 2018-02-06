class pe_metric_curl_cron_jobs::puppetserver (
  Integer       $collection_frequency = $::pe_metric_curl_cron_jobs::collection_frequency,
  Integer       $retention_days       = $::pe_metric_curl_cron_jobs::retention_days,
  String        $metrics_ensure       = $::pe_metric_curl_cron_jobs::puppetserver_metrics_ensure,
  Array[String] $hosts                = $::pe_metric_curl_cron_jobs::puppetserver_hosts,
  Integer       $port                 = $::pe_metric_curl_cron_jobs::puppetserver_port,
  Optional[Pe_metric_curl_cron_jobs::Metrics_server] $metrics_server_info = $::pe_metric_curl_cron_jobs::metrics_server_info,
) {
  Pe_metric_curl_cron_jobs::Pe_metric {
    output_dir     => $::pe_metric_curl_cron_jobs::output_dir,
    scripts_dir    => $::pe_metric_curl_cron_jobs::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  pe_metric_curl_cron_jobs::pe_metric { 'puppetserver' :
    metric_ensure => $metrics_ensure,
    hosts         => $hosts,
    metrics_port  => $port,
    metrics_server_info => $metrics_server_info,
  }

  # DEPRECATION MECHANISMS
  # Ensure remanants of cron jobs and files from older versions of this module
  # are cleaned up.
  pe_metric_curl_cron_jobs::pe_metric { 'puppet_server' :
    metric_ensure => 'absent',
    metrics_port  => 8140,
  }
}
