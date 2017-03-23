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
) {

  $metrics_output_dir = "${output_dir}/${metrics_type}"

  file { $metrics_output_dir :
    ensure => $metric_ensure ? {
      'present' => directory,
      'absent'  => absent,
    },
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
    }),
  }

  cron { "${metrics_type}_metrics_collection" :
    ensure  => $metric_ensure,
    command => $script_file_name,
    user    => 'root',
    minute  => $cron_minute,
  }

  cron { "${metrics_type}_metrics_tidy" :
    ensure  => $metric_ensure,
    user    => 'root',
    hour    => '2',
    command => "find '${metrics_output_dir}' -type f -mtime ${retention_days} -delete",
  }

  cron { "${metrics_type}_metrics_tar" :
    ensure  => $metric_ensure,
    user    => 'root',
    hour    => '1',
    command => "export DIR='${metrics_output_dir}' ; find \"\$DIR\" -type f \! -name \"*.bz2\" > \"\$DIR.tmp\" ; xargs -a \"\$DIR.tmp\" tar -jcf \"\$DIR/${metrics_type}-$(date +%Y%m%d).tar.bz2\" 2>/dev/null ; xargs -a \"\$DIR.tmp\" rm ; rm \"\$DIR.tmp\"",
  }

  #Cleanup old .sh scripts
  $old_script_file_name = "${scripts_dir}/${metrics_type}_metrics.sh"
  file { $old_script_file_name :
    ensure  => absent,
  }
}
