class pe_metric_curl_cron_jobs::puppetdb_metrics (
  String        $metrics_type = 'puppetdb',
  String        $output_dir   = '/opt/puppetlabs/pe_metric_curl_cron_jobs',
  Array[String] $hosts        = [ 'localhost' ],
) {

  $scripts_dir        = "${output_dir}/scripts"
  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $output_dir, $metrics_output_dir :
    ensure => directory,
  }

  file { "${scripts_dir}/puppetdb_metrics.sh" :
    ensure => file,
    content => epp('pe_metric_curl_cron_jobs/puppetdb_metrics.sh.epp',
                  { 'output_dir' => $metrics_output_dir,
                    'hosts'      => $hosts,
                  }),
    mode    => '0744',
  }
}
