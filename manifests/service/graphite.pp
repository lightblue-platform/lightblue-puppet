# == Class: lightblue::service::graphite
#
# Deploys lightblue graphite environment variables.
#
# === Parameters
#
# $hostname - Hostname of the graphite server
# $port     - Port the graphite server is listening on
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# include lightblue::service::data
#
class lightblue::service::graphite ($hostname, $port){

  file { '/etc/profile.d/graphite.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => inline_template("export GRAPHITE_HOSTNAME=${hostname}\nexport GRAPHITE_PORT=${port}")
  }

}