# == Class: lightblue::application::migrator
#
# Deploys lightblue migrator service.
#
# === Parameters
#
# No parameters.
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# class { 'lightblue::application::migrator':
#   #parameters
# }
#
class lightblue::application::migrator (
    $lbclient_metadata_uri,
    $lbclient_data_uri,
    $lbclient_use_cert_auth = false,
    $lbclient_ca_file_path = undef,
    $lbclient_cert_file_path = undef,
    $lbclient_cert_password = undef,
    $lbclient_cert_alias = undef,
    $config_file = 'lightblue-client.properties',
    $service_owner = 'root',
    $service_group = 'root',
    $migrator_version = 'latest',
    $jsvc_version = 'latest',
    $java_home = undef,
    $jar_path = '/usr/share/jbossas/standalone/deployments/consistency-checker-*.jar',
    $service_log_file = 'migrator.log',
    $hostname = '$(hostname)',
    $ip = '$(dig +short $(hostname))',
    $checker_name,
    $job_version,
    $configuration_version,
){
    require lightblue::yumrepo::lightblue
    require lightblue::java

    $migrator_service_name = 'migrator-service'
    $migrator_package_name = 'lightblue-consistency-checker'

    package { $migrator_package_name:
      ensure  => $migrator_version,
      notify  => [Service[$migrator_service_name]],
    }

    lightblue::client::configure { $config_file:
        owner                   => $service_owner,
        group                   => $service_group,
        lbclient_metadata_uri   => $lbclient_metadata_uri,
        lbclient_data_uri       => $lbclient_data_uri,
        lbclient_use_cert_auth  => $lbclient_use_cert_auth,
        lbclient_ca_file_path   => $lbclient_ca_file_path,
        lbclient_cert_file_path => $lbclient_cert_file_path,
        lbclient_cert_password  => $lbclient_cert_password,
        lbclient_cert_alias     => $lbclient_cert_alias,
        notify                  => [Service[$migrator_service_name]],
    }

    class { 'lightblue::application::migrator::daemon':
        jsvc_version        => $jsvc_version,
        owner               => $service_owner,
        group               => $service_group,
        service_name        => $migrator_service_name,
        service_out_logfile => $service_log_file,
        service_err_logfile => $service_log_file,
        java_home          => $java_home,
        jar_path            => $jar_path,
        mainClass           => 'com.redhat.lightblue.migrator.consistency.ConsistencyCheckerDaemon',
        arguments           => {
          config        => $config_file,
          hostname      => $hostname,
          ip            => $ip,
          jobversion    => $job_version,
          name          => $checker_name,
          configversion => $configuration_version,
        },
        require             => [Package[$migrator_package_name]],
    }

    service { $migrator_service_name:
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
    }

}
