# == Class: lightblue::service::graphite
#
# Deploys/Removes lightblue graphite environment variables.
#
# === Parameters
#
# $prefix   - (optional) Prefix used for graphite.
#             Note: If not specified, then lightblue will use other strategies to determine the prefix.
# $hostname - Hostname of the graphite server.
#             If not set, puppet will remove the environment variables.
# $port     - Port the graphite server is listening on
#             Defaults to 2003
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# include lightblue::service::graphite
#
class lightblue::service::plugin::graphite ($prefix = undef, $hostname = undef, $port = 2003){

  $graphite_file = '/etc/profile.d/graphite.sh'

  if($hostname){
    $warning = '#This file is managed by Puppet, any changes will be overridden.'

    file { $graphite_file:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => inline_template("${warning}\n\n<% if(!@prefix.nil?) -%>export GRAPHITE_PREFIX=${prefix}\n<% end -%>export GRAPHITE_HOSTNAME=${hostname}\nexport GRAPHITE_PORT=${port}\n")
    }
  }
  else{
    file { $graphite_file:
      ensure => 'absent'
    }
  }

}
