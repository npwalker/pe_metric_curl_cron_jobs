class pe_metric_curl_cron_jobs (
  # DEPRECATED API ==============================
  Optional[String]        $puppet_server_metrics_ensure  = undef,
  Optional[Array[String]] $puppet_server_hosts           = undef,
  # CURRENT API =================================
  String        $output_dir                    = '/opt/puppetlabs/pe_metric_curl_cron_jobs',
  Integer       $collection_frequency          = 5,
  Integer       $retention_days                = 90,
  String        $puppetserver_metrics_ensure   = pick($pe_metric_curl_cron_jobs::puppet_server_metrics_ensure, 'present'),
  Array[String] $puppetserver_hosts            = pick($pe_metric_curl_cron_jobs::puppet_server_hosts, [ '127.0.0.1' ]),
  Integer       $puppetserver_port             = 8140,
  String        $puppetdb_metrics_ensure       = 'present',
  Array[String] $puppetdb_hosts                = [ '127.0.0.1' ],
  Integer       $puppetdb_port                 = 8081,
  String        $orchestrator_metrics_ensure   = 'present',
  Array[String] $orchestrator_hosts            = [ '127.0.0.1' ],
  Integer       $orchestrator_port             = 8143,
  String        $activemq_metrics_ensure       = 'absent',
  Array[String] $activemq_hosts                = [ '127.0.0.1' ],
  Integer       $activemq_port                 = 8161,
) {
  $scripts_dir = "${output_dir}/scripts"

  file { [ $output_dir, $scripts_dir ] :
    ensure => directory,
  }

  Pe_metric_curl_cron_jobs::Pe_metric {
    output_dir     => $output_dir,
    scripts_dir    => $scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  include pe_metric_curl_cron_jobs::puppetserver

  pe_metric_curl_cron_jobs::pe_metric { 'puppetdb' :
    metric_ensure => $puppetdb_metrics_ensure,
    hosts         => $puppetdb_hosts,
    metrics_port  => $puppetdb_port,
  }

  pe_metric_curl_cron_jobs::pe_metric { 'orchestrator' :
    metric_ensure => $orchestrator_metrics_ensure,
    hosts         => $orchestrator_hosts,
    metrics_port  => $orchestrator_port,
  }

  pe_metric_curl_cron_jobs::pe_metric { 'activemq' :
    metric_ensure => $activemq_metrics_ensure,
    hosts         => $activemq_hosts,
    metrics_port  => $activemq_port,
    metric_script_template => 'activemq_metrics.epp',
  }

  # Emit deprecation warnings if necessary
  if ($puppet_server_metrics_ensure != undef) {
    warning('Using deprecated parameter pe_metric_curl_cron_jobs::puppet_server_metrics_ensure! please use pe_metric_curl_cron_jobs::puppetserver_metrics_ensure instead.')
  }
  if ($puppet_server_hosts != undef) {
    warning('Using deprecated parameter pe_metric_curl_cron_jobs::puppet_server_hosts! please use pe_metric_curl_cron_jobs::puppetserver_hosts instead.')
  }

}
