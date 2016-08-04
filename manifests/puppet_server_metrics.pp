class pe_metric_curl_cron_jobs::puppet_server_metrics (
  String        $output_dir = '/opt/puppetlabs/puppet-server-metrics',
  Array[String] $hosts      = [ 'localhost' ],
) {

  file { $output_dir :
    ensure => directory,
  }

  file { "${output_dir}/puppet-server-metrics.sh" :
    ensure  => file,
    content => epp('pe_metric_curl_cron_jobs/puppet_server_metrics.sh.epp',
                  { 'output_dir' => $output_dir,
                    'hosts'      => $hosts,
                  }),
    mode    => '0744',
  }
}
