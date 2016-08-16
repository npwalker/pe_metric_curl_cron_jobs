define pe_metric_curl_cron_jobs::pe_metric (
  String        $output_dir,
  String        $scripts_dir,
  String        $metrics_type = $title,
  Array[String] $hosts        = [ 'localhost' ],
  String        $cron_minute  = '*/5',
  String        $tidy_age     = '3d',
) {

  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $metrics_output_dir :
    ensure => directory,
  }

  $script_file_name = "${scripts_dir}/${metrics_type}_metrics.sh"

  file { $script_file_name :
    ensure  => file,
    content => epp("pe_metric_curl_cron_jobs/${metrics_type}_metrics.sh.epp",
                  { 'output_dir' => $metrics_output_dir,
                    'hosts'      => $hosts,
                  }),
    mode    => '0744',
  }

  cron { "${metrics_type}_metrics_collection" :
    command => $script_file_name,
    user    => 'root',
    minute  => $cron_minute,
  }

  cron { "${metrics_type}_metrics_tidy" :
    command => epp("pe_metric_curl_cron_jobs/tidy_apply.epp",
                  { 'output_dir' => $metrics_output_dir,
                    'tidy_age'   => $tidy_age,
                  }),
    user    => 'root',
    hour    => '2',
  }
}
