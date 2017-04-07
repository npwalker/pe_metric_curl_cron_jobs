class pe_metric_curl_cron_jobs::orchestrator (
  Integer       $collection_frequency = $::pe_metric_curl_cron_jobs::collection_frequency,
  Integer       $retention_days       = $::pe_metric_curl_cron_jobs::retention_days,
  String        $metrics_ensure       = $::pe_metric_curl_cron_jobs::orchestrator_metrics_ensure,
  Array[String] $hosts                = $::pe_metric_curl_cron_jobs::orchestrator_hosts,
  Integer       $port                 = $::pe_metric_curl_cron_jobs::orchestrator_port,
) {
  Pe_metric_curl_cron_jobs::Pe_metric {
    output_dir     => $::pe_metric_curl_cron_jobs::output_dir,
    scripts_dir    => $::pe_metric_curl_cron_jobs::scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  pe_metric_curl_cron_jobs::pe_metric { 'orchestrator' :
    metric_ensure => $metrics_ensure,
    hosts         => $hosts,
    metrics_port  => $port,
  }
}
