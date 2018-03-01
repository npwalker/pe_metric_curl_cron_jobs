class puppet_metrics_collector (
  String        $output_dir                    = '/opt/puppetlabs/puppet-metrics-collector',
  Integer       $collection_frequency          = 5,
  Integer       $retention_days                = 90,
  String        $puppetserver_metrics_ensure   = present,
  Array[String] $puppetserver_hosts            = [ '127.0.0.1' ],
  Integer       $puppetserver_port             = 8140,
  String        $puppetdb_metrics_ensure       = 'present',
  Array[String] $puppetdb_hosts                = [ '127.0.0.1' ],
  Integer       $puppetdb_port                 = 8081,
  String        $orchestrator_metrics_ensure   = 'present',
  Array[String] $orchestrator_hosts            = [ '127.0.0.1' ],
  Integer       $orchestrator_port             = 8143,
  String        $activemq_metrics_ensure       = 'absent',
  Array[String] $activemq_hosts                = [ '127.0.0.1' ],
  Integer       $activemq_port                 = 8161,
  Boolean       $symlink_puppet_metrics_collector = true,
) {
  $scripts_dir = "${output_dir}/scripts"
  $bin_dir     = "${output_dir}/bin"

  file { [ $output_dir, $scripts_dir, $bin_dir] :
    ensure => directory,
  }

  file { "${scripts_dir}/tk_metrics" :
    ensure  => present,
    mode    => '0755',
    source  => 'puppet:///modules/puppet_metrics_collector/tk_metrics'
  }

  file { "${bin_dir}/puppet-metrics-collector":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('puppet_metrics_collector/puppet-metrics-collector.epp', {
      'output_dir' => $output_dir,
    }),
  }

  $symlink_ensure = $symlink_puppet_metrics_collector ? {
    false  => 'absent',
    true   => 'symlink',
  }

  file { "/opt/puppetlabs/bin/puppet-metrics-collector":
    ensure => $symlink_ensure,
    target => "${bin_dir}/puppet-metrics-collector",
  }

  include puppet_metrics_collector::puppetserver
  include puppet_metrics_collector::puppetdb
  include puppet_metrics_collector::orchestrator
  include puppet_metrics_collector::activemq
}
