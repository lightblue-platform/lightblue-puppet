# == Class: lightblue::jcliff
#
# Configure jcliff (https://github.com/bserdar/jcliff) so we can configure jboss!
#
# === Parameters
#
# config_dir : directory containing jcliff config files. Must exist before this instantiated
# management_host : The eap6 host
# management_port : The management port for eap6
# jboss_home : Path to eap6, /usr/share/jbossas
# enable_logging : If true, jcliff logs
# log_dir : The jcliff logging directory
# deploy_apps : if true, apps are deployed as well (*.deploy files under config_dir)
#
# === Examples
#
#  include lightblue::jcliff
#
class lightblue::jcliff (
  $config_dir=undef,
  $management_host='localhost',
  $management_port=undef,
  $jboss_home='/usr/share/jbossas',
  $enable_logging=false,
  $log_dir=undef,
  $deploy_apps=true,
  $package_name='jcliff',
  $package_ensure=latest,
) {
    include lightblue::eap

    package { $package_name :
        ensure  => $package_ensure,
        require => Class['lightblue::yumrepo::jbeaptools'],
    }

    $jcliff_config_dir=$config_dir

    if $enable_logging {
        $jcliff_log_dir_option = "-v --output=${log_dir}/jbosscfg.log"
    }
    else {
        $jcliff_log_dir_option = ''
    }

    exec { 'configure-eap6' :
        command      => "/usr/bin/jcliff --cli=${jboss_home}/bin/jboss-cli.sh --controller=${management_host}:${management_port} ${jcliff_log_dir_option} ${config_dir}/*.conf",
        logoutput    => true,
        timeout      => 0,
        onlyif       => "ls ${config_dir}/*.conf",
        require      => [ Class['lightblue::eap'], Service['jbossas'], Package['jcliff'], File[$log_dir] ],
        notify       => [ Exec['deploy-apps'], Exec['reload-check'] ],
    }

    if $deploy_apps {
      exec { 'deploy-apps' :
          command   =>  "/usr/bin/jcliff --cli=${jboss_home}/bin/jboss-cli.sh -v --controller=${management_host}:${management_port} --output=${log_dir}/deployments.log ${config_dir}/*.deploy",
          logoutput => true,
          timeout   => 0,
          onlyif    => "ls ${config_dir}/*.deploy",
          require   => Exec['configure-eap6'],
          notify    => Exec['reload-check'],
      }
    }

    exec { 'clean-eap6-configs' :
        command => "rm -f ${config_dir}/*.conf",
        require => [ File[$config_dir]],
    }

    exec { 'reload-check' :
        onlyif      => "${jboss_home}/bin/jboss-cli.sh --controller=${management_host}:${management_port} --connect \":read-attribute(name=server-state)\" | grep reload-required",
        command     => 'service jbossas restart',
        user        => 'jboss',
        group       => 'jboss',
        refreshonly => true
    }
}
