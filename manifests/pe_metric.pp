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
  Optional[Pe_metric_curl_cron_jobs::Metrics_server] $metrics_server_info = undef,
) {

  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $metrics_output_dir :
    ensure => $metric_ensure ? {
      'present' => directory,
      'absent'  => absent,
    },
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
    mode    => '0644',
    content => $config_hash.pe_metric_curl_cron_jobs::to_yaml(),
  }

  $script_file_name = "${scripts_dir}/${metric_script_file}"
  $conversion_script_file_name = "${scripts_dir}/json2timeseriesdb"

  $metrics_base_command = "${script_file_name} --metrics_type ${metrics_type} --output-dir ${metrics_output_dir}"

  if !empty($metrics_server_info) {
    $metrics_server_hostname = $metrics_server_info['hostname']
    $metrics_server_port     = $metrics_server_info['port']
    $metrics_server_type     = $metrics_server_info['metrics_server_type']
    $metrics_server_db       = $metrics_server_info['db_name']

    if empty($metrics_server_db) and $metrics_server_type == 'influxdb'  {
      fail( 'When using an influxdb server you must provide the db_name to store metrics in' )
    }

    $local_metrics_command = "${metrics_base_command} | ${conversion_script_file_name} --netcat ${metrics_server_hostname} --convert-to ${metrics_server_type}"

    $port_metrics_command = empty($metrics_server_port) ? {
      false => "${local_metrics_command} --port ${metrics_server_port}",
      true  => $local_metrics_command,
    }

    $metrics_command = $metrics_server_type ? {
      'influxdb' => "${port_metrics_command} --influx-db ${metrics_server_db}",
      'graphite' => $port_metrics_command,
      default    => $port_metrics_command,
    }
  } else {
    $metrics_command = "${metrics_base_command} --no-print"
  }

  cron { "${metrics_type}_metrics_collection" :
    ensure  => $metric_ensure,
    command => $metrics_command,
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

  #Cleanup old scripts
  $old_script_file_names = [
    "${scripts_dir}/${metrics_type}_metrics.sh",
    "${scripts_dir}/${metrics_type}_metrics"
  ]

  file { $old_script_file_names :
    ensure  => absent,
  }
}
