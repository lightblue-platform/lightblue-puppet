# Installs EAP6 from internal repos
# Declares a service to control eap6 instance
class lightblue::eap (
    $eap_version = '6.1.0',
) {
  include lightblue::yumrepo::jbeap
  include lightblue::yumrepo::jbeaptools
  include lightblue::java

  $config_dir = hiera('lightblue::eap::config_dir', '/etc/redhat/lightblue')
  $package_name = hiera('lightblue::eap::package::name', 'jbossas-standalone')
  $package_ensure = hiera('lightblue::eap::package::ensure', latest)

  package { $package_name :
    ensure  => $package_ensure,
    require => [Class['lightblue::yumrepo::jbeap'], Class['lightblue::yumrepo::jbeaptools'], Class['lightblue::java']],
  }

  file { [ '/etc/redhat', $config_dir ] :
    ensure   => 'directory',
    owner    => 'jboss',
    group    => 'jboss',
    mode     => '0755',
    require  => Package[$package_name],
  }

  $jboss_java_opts_Xms = hiera('lightblue::eap::java::Xms', '786m')
  $jboss_java_opts_Xmx = hiera('lightblue::eap::java::Xmx', '1572m')

  # bind jboss to the correct address
  file { '/usr/share/jbossas/bin/standalone.conf':
    content => template('lightblue/standalone.conf.erb'),
    owner   => 'jboss',
    group   => 'jboss',
    mode    => '0644',
    require => Package[$package_name],
    notify  => Service['jbossas'],
  }

  # fix logs dir to symlink correctly
  file { '/var/lib/jbossas/standalone/log/':
    ensure  => 'link',
    force   => true,
    owner   => 'jboss',
    group   => 'jboss',
    mode    => '0755',
    target  => '/var/log/jbossas/standalone/',
    require => Package[$package_name],
    before  => Service['jbossas'],
  }

  #Configure JBOSS for startup
  service { 'jbossas':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    status     => '/sbin/service jbossas status | /bin/grep running',
    require    => Package[$package_name],
  }

  #socket bindings
  lightblue::jcliff::config { 'socketbinding.conf':
    content => template('lightblue/socketbinding.conf.erb')
  }
}
