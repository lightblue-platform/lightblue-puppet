# Defines a web connector
define lightblue::eap::thread_pool (
  $pool_type='',
  $core_thread_count='',
  $handoff_executor='',
  $keepalive_time='',
  $max_thread_count='',
  $queue_length='',
  $thread_factory='',
) {
  lightblue::jcliff::config { "thread-pool-${name}.conf":
    content => template('lightblue/thread-pool.conf.erb'),
  }
}
