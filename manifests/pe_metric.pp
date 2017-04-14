define pe_metric_curl_cron_jobs::pe_metric (
  Enum['absent', 'present'] $metric_ensure  = 'present',
  String                    $output_dir,
  String                    $scripts_dir,
  Integer                   $metrics_port,
  String                    $metrics_type   = $title,
  Array[String]             $hosts          = [ '127.0.0.1' ],
  String                    $cron_minute    = '*/5',
  Integer                   $retention_days = 90,
  String                    $metric_script_template = 'tk_metrics.epp',
  Array[Hash]               $additional_metrics     = [],
) {

  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $metrics_output_dir :
    ensure => $metric_ensure ? {
      'present' => directory,
      'absent'  => absent,
    },
  }

  $config_hash = {
    'output_dir'         => $metrics_output_dir,
    'hosts'              => $hosts,
    'metrics_type'       => $metrics_type,
    'metrics_port'       => $metrics_port,
    'additional_metrics' => $additional_metrics,
    'clientcert'         => $::clientcert,
  }

  file { "${scripts_dir}/${metrics_type}_config.yaml" :
    ensure  => $metric_ensure,
    mode    => '0644',
    content => $config_hash.pe_metric_curl_cron_jobs::to_yaml(),
  }

  $script_file_name = "${scripts_dir}/${metrics_type}_metrics"

  file { $script_file_name :
    ensure  => $metric_ensure,
    mode    => '0744',
    content => epp("pe_metric_curl_cron_jobs/${metric_script_template}", {
      'output_dir'    => $metrics_output_dir,
      'hosts'         => $hosts,
      'metrics_type'  => $metrics_type,
      'metrics_port'  => $metrics_port,
      'additional_metrics' => $additional_metrics,
    }),
  }

  cron { "${metrics_type}_metrics_collection" :
    ensure  => $metric_ensure,
    command => "${script_file_name} --metrics_type ${metrics_type}",
    user    => 'root',
    minute  => $cron_minute,
  }

  $metrics_tidy_script_path = "${scripts_dir}/${metrics_type}_metrics_tidy"

  file { $metrics_tidy_script_path :
    ensure  => $metric_ensure,
    mode    => '0744',
    content => epp('pe_metric_curl_cron_jobs/tidy_cron.epp',
                   { 'metrics_output_dir' => $metrics_output_dir,
                     'metrics_type'       => $metrics_type,
                     'retention_days'     => $retention_days,
                   }),
  }

  cron { "${metrics_type}_metrics_tidy" :
    ensure  => $metric_ensure,
    user    => 'root',
    hour    => fqdn_rand(3,  $metrics_type ),
    minute  => (5 * fqdn_rand(11, $metrics_type )),
    command => $metrics_tidy_script_path
  }

  #Cleanup old .sh scripts
  $old_script_file_name = "${scripts_dir}/${metrics_type}_metrics.sh"
  file { $old_script_file_name :
    ensure  => absent,
  }
}
