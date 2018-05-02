class pe_metric_curl_cron_jobs::activemq (
  Integer       $collection_frequency = $::pe_metric_curl_cron_jobs::collection_frequency,
  Integer       $retention_days       = $::pe_metric_curl_cron_jobs::retention_days,
  String        $metrics_ensure       = $::pe_metric_curl_cron_jobs::activemq_metrics_ensure,
  Array[String] $hosts                = $::pe_metric_curl_cron_jobs::activemq_hosts,
  Integer       $port                 = $::pe_metric_curl_cron_jobs::activemq_port,
  Optional[Pe_metric_curl_cron_jobs::Metrics_server] $metrics_server_info = $::pe_metric_curl_cron_jobs::metrics_server_info,
) {
  $scripts_dir = $::pe_metric_curl_cron_jobs::scripts_dir

  Pe_metric_curl_cron_jobs::Pe_metric {
    output_dir     => $::pe_metric_curl_cron_jobs::output_dir,
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
    source  => 'puppet:///modules/pe_metric_curl_cron_jobs/amq_metrics',
  }

  pe_metric_curl_cron_jobs::pe_metric { 'activemq' :
    metric_ensure          => $metrics_ensure,
    hosts                  => $hosts,
    metrics_port           => $port,
    metric_script_file     => 'amq_metrics',
    additional_metrics     => $additional_metrics,
    metrics_server_info    => $metrics_server_info,
  }
}
