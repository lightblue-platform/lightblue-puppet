# Defines a web connector
# Define the web connectors to be used in the node in the client
# module, something like this.
#
# HTTP:
#
#  lightblue::eap::thread_pool { 'httpexecutor' :
#    pool_type         => 'blocking-bounded-queue-thread-pool',
#    max_thread_count  => $http_thread_max,
#    queue_length      => $http_thread_queue,
#    keepalive_time    => $http_thread_keepalive_seconds,
#  }
#
#  lightblue::eap::webconnector { 'http' :
#    executor        => 'httpexecutor',
#    max_connections => $http_max_connections,
#    proxy_name      => $proxy_fqdn,
#    proxy_port      => '80',
#  }
#
# HTTPS:
#
#  if $enable_ssl {
#      lightblue::eap::thread_pool { 'https_executor' :
#        pool_type         => 'blocking-bounded-queue-thread-pool',
#        max_thread_count  => $http_thread_max,
#        queue_length      => $http_thread_queue,
#        keepalive_time    => $http_thread_keepalive_seconds,
#      }
#
#      lightblue::eap::webconnector { 'https' :
#        executor                => 'https_executor',
#        max_connections         => $http_max_connections,
#        proxy_name              => $proxy_fqdn,
#        proxy_port              => '443',
#        socket_binding          => 'https',
#        scheme                  => 'https',
#        protocol                => 'HTTP/1.1',
#        ssl                     => 'ssl',
#        key_alias               => $ssl_keystore_alias,
#        ca_certificate_file     => "$jboss_keystore_location/eap6trust.keystore",
#        certificate_key_file    => "$jboss_keystore_location/eap6.keystore",
#        secure                  => true,
#        password                => $ks_password,
#      }
#  }
define lightblue::eap::webconnector (
  $enable_lookups='',
  $enabled='',
  $executor='',
  $max_connections='',
  $max_post_size='',
  $max_save_post_size='',
  $protocol='',
  $proxy_name='',
  $proxy_port='',
  $redirect_port='',
  $scheme='',
  $secure='',
  $socket_binding='',
  $ssl='',
  $virtual_server='',
  $password='',
  $certificate_key_file='',
  $key_alias='',
  $ca_certificate_file='',
  $ca_certificate_password=''
) {

  lightblue::jcliff::config { "web-connector-${name}.conf":
    content => template('libeap6/web-connector.conf.erb'),
  }
}
