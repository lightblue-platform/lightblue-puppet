# == Class: lightblue::service::graphite
#
# Deploys/Removes lightblue graphite environment variables.
#
# === Parameters
#
# $prefix   - (optional) Prefix used for statsd.
#             Note: If not specified, then lightblue will use other strategies to determine the prefix.
# $hostname - Hostname of the statsd server.
#             If not set, puppet will remove the environment variables.
# $port     - Port the statsd server is listening on
#             Defaults to 8125
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# include lightblue::service::plugin::statsd
#
class lightblue::service::plugin::statsd ($prefix = undef, $hostname = undef, $port = 8125){

  $statsd_file = '/etc/profile.d/lb-statsd.sh'

  if($hostname){
    $warning = '#This file is managed by Puppet, any changes will be overridden.'

    file { $statsd_file:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => inline_template("${warning}\n\n<% if(!@prefix.nil?) -%>export STATSD_PREFIX=${prefix}\n<% end -%>export STATSD_HOSTNAME=${hostname}\nexport STATSD_PORT=${port}\n")
    }
  }
  else{
    file { $statsd_file:
      ensure => 'absent'
    }
  }

}
