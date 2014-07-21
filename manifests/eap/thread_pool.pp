# == Class: lightblue::eap::thread_pool
#
# Deploy thread_pool with use in web connector (to enable ssl).
#
# === Parameters
#
# [*pool_type*]
# [*core_thread_count*]
# [*handoff_executor*]
# [*keepalive_time*]
# [*max_thread_count*]
# [*queue_length*]
# [*thread_factory*]
#
# === Variables
#
# Module requires no global variables.
#
# === Examples
#
#  lightblue::eap::thread_pool { 'http_executor' :
#    pool_type         => 'blocking-bounded-queue-thread-pool',
#    max_thread_count  => $http_thread_max,
#    queue_length      => $http_thread_queue,
#    keepalive_time    => $http_thread_keepalive_seconds,
#  }
#
class lightblue::eap::thread_pool (
  $pool_type,
  $core_thread_count,
  $handoff_executor,
  $keepalive_time,
  $max_thread_count,
  $queue_length,
  $thread_factory,
)
{
  lightblue::jcliff::config { "thread-pool-${name}.conf":
    content => template('lightblue/thread-pool.conf.erb'),
  }
}
