define pe_metric_curl_cron_jobs::pe_metric (
  Enum['absent', 'present'] $metric_ensure  = 'present',
  String                    $output_dir,
  String                    $scripts_dir,
  Integer                   $metrics_port,
  String                    $metrics_type   = $title,
  Array[String]             $hosts          = [ '127.0.0.1' ],
  String                    $cron_minute    = '*/5',
  Integer                   $retention_days = 90,
  String                    $metric_script_file = 'tk_metrics',
  Array[Hash]               $additional_metrics = [],
  Boolean                   $ssl                = true,
) {

  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $metrics_output_dir :
    ensure => $metric_ensure ? {
      'present' => directory,
      'absent'  => absent,
    },
    owner  => 'pe_metric_curl_cron_jobs',
    group  => 'pe_metric_curl_cron_jobs',
    mode   => '0755',
  }

  $config_hash = {
    'hosts'              => $hosts.sort(),
    'metrics_type'       => $metrics_type,
    'metrics_port'       => $metrics_port,
    'additional_metrics' => $additional_metrics,
    'clientcert'         => $::clientcert,
    'pe_version'         => $facts['pe_server_version'],
    'ssl'                => $ssl,
  }

  file { "${scripts_dir}/${metrics_type}_config.yaml" :
    ensure  => $metric_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => $config_hash.pe_metric_curl_cron_jobs::to_yaml(),
  }

  $script_file_name = "${scripts_dir}/${metric_script_file}"

  # Old versions of this module ran collection as root
  cron { "${metrics_type}_metrics_collection" :
    ensure => absent,
    user   => 'root',
  }

  cron { "pe_metric_curl_cron_jobs: ${metrics_type}_metrics_collection" :
    ensure  => $metric_ensure,
    command => "${script_file_name} --metrics_type ${metrics_type} --output-dir ${metrics_output_dir} --no-print",
    user    => 'pe_metric_curl_cron_jobs',
    minute  => $cron_minute,
  }

  $metrics_tidy_script_path = "${scripts_dir}/${metrics_type}_metrics_tidy"

  file { $metrics_tidy_script_path :
    ensure  => $metric_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
    content => epp('pe_metric_curl_cron_jobs/tidy_cron.epp',
                   { 'metrics_output_dir' => $metrics_output_dir,
                     'metrics_type'       => $metrics_type,
                     'retention_days'     => $retention_days,
                   }),
  }

  # Old versions of this module ran tidy as root
  cron { "${metrics_type}_metrics_tidy" :
    ensure => absent,
    user   => 'root',
  }

  cron { "pe_metric_curl_cron_jobs: ${metrics_type}_metrics_tidy" :
    ensure  => $metric_ensure,
    user    => 'pe_metric_curl_cron_jobs',
    hour    => fqdn_rand(3,  $metrics_type ),
    minute  => (5 * fqdn_rand(11, $metrics_type )),
    command => $metrics_tidy_script_path
  }

  #Cleanup old scripts
  $old_script_file_names = [
    "${scripts_dir}/${metrics_type}_metrics.sh",
    "${scripts_dir}/${metrics_type}_metrics"
  ]

  file { $old_script_file_names :
    ensure  => absent,
  }
}
