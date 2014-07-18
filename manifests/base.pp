# Sets up a base node with java, EAP6, jcliff, and lightblue module
class lightblue::base {

  include lightblue::yumrepos
  include lightblue::java
  include lightblue::eap
  include lightblue::eap::logging
  include lightblue::eap::module

  $config_dir = '/etc/redhat/lightblue'

  file { [ '/etc/redhat', $config_dir ] :
    ensure   => 'directory',
    owner    => 'jboss',
    group    => 'jboss',
    mode     => '0755',
    require  => Package['jbossas-standalone'],
  }

  class { 'lightblue::jcliff':
    config_dir      => $config_dir,
    management_host => $::ipaddress,
    management_port => 9999,
    log_dir         => '/var/lib/jbossas/standalone/log',
    enable_logging  => true,
    deploy_apps     => true,
    require         => Class['lightblue::eap'],
  }

  #socket bindings
  lightblue::jcliffconfig { 'socketbinding.conf':
    content => template('lightblue/socketbinding.conf.erb')
  }
}
