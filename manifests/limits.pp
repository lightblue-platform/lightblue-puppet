# == Class: lightblue::limits
#
# Configures limits for user jboss in /etc/security/limits.d/10-lightblue.conf
#
# === Parameters
#
# [*soft_nproc*]
#   The soft nproc limit for user jboss.
#
# [*hard_nproc*]
#   The hard nproc limit for user jboss.
#
# [*soft_nofile*]
#   The soft nofile limit for user jboss.
#
# [*hard_nofile*]
#   The hard nofile limit for user jboss.
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::limits (
    $soft_nproc = undef,
    $hard_nproc = undef,
    $soft_nofile = undef,
    $hard_nofile = undef
) {
  file { '/etc/security/limits.d/10-lightblue.conf':
    ensure  => 'file',
    content => template('lightblue/limits/10-lightblue.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
