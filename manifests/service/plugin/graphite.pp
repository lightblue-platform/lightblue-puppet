# == Class: lightblue::service::graphite
#
# Deploys/Removes lightblue graphite environment variables.
#
# === Parameters
#
# $hostname - Hostname of the graphite server.
#             If not set, puppet will remove the environment variables.
# $port     - Port the graphite server is listening on
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# include lightblue::service::graphite
#
class lightblue::service::plugin::graphite ($hostname = undef, $port = undef){

  $graphite_file = '/etc/profile.d/graphite.sh'

  if($hostname){
    if(!$port){
      fail('If providing a graphite hostname, a port must also be provided.')
    }

    file { $graphite_file:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => inline_template("export GRAPHITE_HOSTNAME=${hostname}\nexport GRAPHITE_PORT=${port}")
    }
  }
  else{
    file { $graphite_file:
      ensure => 'absent'
    }
  }

}
