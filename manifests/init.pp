class pe_metric_curl_cron_jobs (
  $output_dir = '/opt/puppetlabs/pe_metric_curl_cron_jobs'
) {

  $scripts_dir        = "${output_dir}/scripts"

  file { [ $output_dir, $scripts_dir ] :
    ensure => directory,
  }

  Pe_metric_curl_cron_jobs::Pe_metric {
    output_dir  => $output_dir,
    scripts_dir => $scripts_dir,
  }

  pe_metric_curl_cron_jobs::pe_metric { 'puppetdb': }
  pe_metric_curl_cron_jobs::pe_metric { 'puppet_server': }

}
