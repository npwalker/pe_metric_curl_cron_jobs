class puppet_metrics_collector::activemq (
  Integer       $collection_frequency = $puppet_metrics_collector::collection_frequency,
  Integer       $retention_days       = $puppet_metrics_collector::retention_days,
  String        $metrics_ensure       = $puppet_metrics_collector::activemq_metrics_ensure,
  Array[String] $hosts                = $puppet_metrics_collector::activemq_hosts,
  Integer       $port                 = $puppet_metrics_collector::activemq_port,
) {
  $scripts_dir = $::puppet_metrics_collector::scripts_dir

  Puppet_metrics_collector::Pe_metric {
    output_dir     => $::puppet_metrics_collector::output_dir,
    scripts_dir    => $scripts_dir,
    cron_minute    => "*/${collection_frequency}",
    retention_days => $retention_days,
  }

  $additional_metrics = [
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:type=Memory',
      'attribute' => 'HeapMemoryUsage,NonHeapMemoryUsage'
    },
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:name=*,type=GarbageCollector',
      'attribute' => 'CollectionCount'
    },
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:type=Runtime',
      'attribute' => 'Uptime'
    },
    {
      'type'      => 'read',
      'mbean'     => 'java.lang:type=OperatingSystem',
      'attribute' => 'OpenFileDescriptorCount,MaxFileDescriptorCount'
    },
    {
      'type'      => 'read',
      'mbean'     => 'org.apache.activemq:brokerName=*,type=Broker',
      'attribute' => 'MemoryLimit,MemoryPercentUsage,CurrentConnectionsCount'
    },
    {
      'type'      => 'read',
      'mbean'     => 'org.apache.activemq:type=Broker,brokerName=*,destinationType=Queue,destinationName=mcollective.*',
      'attribute' => 'AverageBlockedTime,AverageEnqueueTime,AverageMessageSize,ConsumerCount,DequeueCount,DispatchCount,EnqueueCount,ExpiredCount,ForwardCount,InFlightCount,ProducerCount,QueueSize',
    },
    {
      'type'      => 'read',
      'mbean'     => 'org.apache.activemq:type=Broker,brokerName=*,destinationType=Topic,destinationName=mcollective.*.agent',
      'attribute' => 'AverageBlockedTime,AverageEnqueueTime,AverageMessageSize,ConsumerCount,DequeueCount,DispatchCount,EnqueueCount,ExpiredCount,ForwardCount,InFlightCount,ProducerCount,QueueSize',
    },
  ]

  file { "${scripts_dir}/amq_metrics" :
    ensure  => present,
    mode    => '0744',
    source  => 'puppet:///modules/puppet_metrics_collector/amq_metrics',
  }

  puppet_metrics_collector::pe_metric { 'activemq' :
    metric_ensure          => $metrics_ensure,
    hosts                  => $hosts,
    metrics_port           => $port,
    metric_script_file     => 'amq_metrics',
    additional_metrics     => $additional_metrics,
  }
}
