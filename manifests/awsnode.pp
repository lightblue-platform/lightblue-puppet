class lightblue::awsnode {

  include lightblue::openjdk
  include lightblue::eap

  file { [ '/etc/redhat', '/etc/redhat/lightblue' ] :
    ensure   => 'directory',
    owner    => 'jboss',
    group    => 'jboss',
    mode     => '0755',
    require  => [ User['jboss'] ]
  }

  class { 'lightblue::jcliff':
    config_dir      => '/etc/redhat/lightblue',
    management_host => 'localhost',
    management_port => 9999,
    log_dir         => '/usr/share/jbossas/standalone/log',
    enable_logging  => true,
    deploy_apps     => true,
    require         => [ File['/etc/redhat/lightblue'] ],
  }

}
