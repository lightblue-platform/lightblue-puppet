# Lay down a jcliff config file, and schedule execution of config update
# name gives the name of the file, without directory
define lightblue::jcliff::config($content) {
  class { 'lightblue::jcliff':
    config_dir      => $config_dir,
    management_host => $::ipaddress,
    management_port => 9999,
    log_dir         => '/var/lib/jbossas/standalone/log',
    enable_logging  => true,
    deploy_apps     => true,
    require         => Class['lightblue::eap'],
  }

  file{ "${lightblue::jcliff::jcliff_config_dir}/$name":
    mode   => '0644',
    owner  => 'jboss',
    group  => 'jboss',
    content=> $content,
    notify => Exec['configure-eap6'],
    require=> [ Package['jcliff'], Exec['clean-eap6-configs'] ],
  }
}
