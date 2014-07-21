# == Class: lightblue::eap::webconnector
#
# Define the web connectors.
#
# === Parameters
#
# [*enable_lookups*]
# [*enabled*]
# [*executor*]
# [*max_connections*]
# [*max_post_size*]
# [*max_save_post_size*]
# [*protocol*]
# [*proxy_name*]
# [*proxy_port*]
# [*redirect_port*]
# [*scheme*]
# [*secure*]
# [*socket_binding*]
# [*ssl*]
# [*virtual_server*]
# [*password*]
# [*certificate_key_file*]
# [*key_alias*]
# [*ca_certificate_file*]
# [*ca_certificate_password*]
# [*ntp_servers*]
#
# === Variables
#
# Module requires no global variables.
#
# === Examples
#
# HTTP:
#
#  lightblue::eap::webconnector { 'http' :
#    executor        => 'http_executor',
#    max_connections => $http_max_connections,
#    proxy_name      => $proxy_fqdn,
#    proxy_port      => '80',
#  }
#
# HTTPS:
#
#  lightblue::eap::webconnector { 'https' :
#    executor                => 'https_executor',
#    max_connections         => $http_max_connections,
#    proxy_name              => $proxy_fqdn,
#    proxy_port              => '443',
#    socket_binding          => 'https',
#    scheme                  => 'https',
#    protocol                => 'HTTP/1.1',
#    ssl                     => 'ssl',
#    key_alias               => $ssl_keystore_alias,
#    ca_certificate_file     => "$jboss_keystore_location/eap6trust.keystore",
#    certificate_key_file    => "$jboss_keystore_location/eap6.keystore",
#    secure                  => true,
#    password                => $ks_password,
#  }
#
class lightblue::eap::webconnector (
  $enable_lookups,
  $enabled,
  $executor,
  $max_connections,
  $max_post_size,
  $max_save_post_size,
  $protocol,
  $proxy_name,
  $proxy_port,
  $redirect_port,
  $scheme,
  $secure,
  $socket_binding,
  $ssl,
  $virtual_server,
  $password,
  $certificate_key_file,
  $key_alias,
  $ca_certificate_file,
  $ca_certificate_password,
) {

  lightblue::jcliff::config { "web-connector-${name}.conf":
    content => template('lightblue/web-connector.conf.erb'),
  }
}
