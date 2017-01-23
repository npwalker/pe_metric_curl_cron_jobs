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

  pe_metric_curl_cron_jobs::pe_metric { 'puppetdb' :
    metric_ensure => $puppetdb_metrics_ensure,
    hosts         => $puppetdb_hosts,
  }

}
