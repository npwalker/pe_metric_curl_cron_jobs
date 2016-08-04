define pe_metric_curl_cron_jobs::pe_metric (
  String        $output_dir,
  String        $scripts_dir,
  String        $metrics_type = $title,
  Array[String] $hosts        = [ 'localhost' ],
) {

  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $metrics_output_dir :
    ensure => directory,
  }

  file { "${scripts_dir}/${metrics_type}_metrics.sh" :
    ensure => file,
    content => epp("pe_metric_curl_cron_jobs/${metrics_type}_metrics.sh.epp",
                  { 'output_dir' => $metrics_output_dir,
                    'hosts'      => $hosts,
                  }),
    mode    => '0744',
  }
}
