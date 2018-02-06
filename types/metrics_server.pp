type Pe_metric_curl_cron_jobs::Metrics_server = Struct[{
  metrics_server_type => Enum['influxdb','graphite'],
  hostname            => String,
  port                => Optional[Integer],
  db_name             => Optional[String],
}]
