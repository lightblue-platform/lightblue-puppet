# == Class: lightblue::eap
#
# Installs JBoss EAP and declares a service to control EAP.
#
# === Parameters
#
# [*config_dir*]
#   The director in which jcliff configuration files are deployed.
#
# [*package_name*]
#   The package name for JBoss EAP.
#
# [*package_ensure*]
#   For 'ensure' value for the JBoss EAP package.
#   See https://docs.puppetlabs.com/references/latest/type.html#package-attribute-ensure
#
# [*java_Xms*]
#   Xms value for the java process.
#
# [*java_Xmx*]
#   Xmx value for the java process.
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::eap (
    $config_dir = '/etc/redhat/lightblue',
    $package_name = 'jbossas-standalone',
    $package_ensure = latest,
    $java_Xms = '786m',
    $java_Xmx = '1572m',
) {
  include lightblue::yumrepo::jbeap
  include lightblue::yumrepo::jbeaptools
  include lightblue::java

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
