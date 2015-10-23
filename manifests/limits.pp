# == Class: lightblue::limits
#
# Configures limits in /etc/security/limits.conf
#
# === Parameters
#
# [*config_dir*]
#   The director in which jcliff configuration files are deployed.
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::limits (
    $soft_nproc = undef,
    $hard_nproc = undef
) {
  file { '/etc/security/limits.d/10-nproc.conf':
    ensure  => 'file',
    content => template('lightblue/limits/nproc.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
