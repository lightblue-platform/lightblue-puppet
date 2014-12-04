# == Class: lightblue::application::migrator
#
# Deploys lightblue migrator service.
#
# === Parameters
#
# $lbclient_metadata_uri   - see lightblue::client::configure
# $lbclient_data_uri       - see lightblue::client::configure
# $lbclient_use_cert_auth  - see lightblue::client::configure
# $lbclient_ca_file_path   - see lightblue::client::configure
# $lbclient_cert_file_path - see lightblue::client::configure
# $lbclient_cert_password  - see lightblue::client::configure
# $lbclient_cert_alias     - see lightblue::client::configure
# $config_file             - (required) Lightblue Client configuration file
# $service_owner           - Owner of service and related files. Defaults to root.
# $service_group           - Group of service and related files. Defaults to root.
# $migrator_version        - Version of consistency-checker rpm to install. Defaults to latest.
# $jsvc_version            - Version of the jsvc package to install. Defaults to latest.
# $java_home               - (optional) Specify the java home directory. Defaults to JAVA_HOME.
# $jar_path                - (optional) Specify the path to the jar file to be wrapped in the service.
# $service_log_file        - Path to log out/err message too.
# $checker_name            - Name of this consistency-checker.
# $hostname                - Hostname to pass into consistency-checker. Defaults to $(hostname)
# $configuration_version   - Configuration version to pass into consistency-checker.
# $job_version             - Job version to pass into consistency-checker.
# $source_config           - Source lightblue client configuration file. Defaults to $config_file.
# $destination_config      - Destination lightblue client configuration file. Defaults to $config_file.
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
    $checker_name,
    $hostname = '$(hostname)',
    $job_version,
    $configuration_version,
    $source_config = undef,
    $destination_config = undef,
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
        java_home           => $java_home,
        jar_path            => $jar_path,
        mainClass           => 'com.redhat.lightblue.migrator.consistency.ConsistencyCheckerDaemon',
        arguments           => {
          name              => $checker_name,
          hostname          => $hostname,
          config            => $config_file,
          configversion     => $configuration_version,
          jobversion        => $job_version,
          sourceconfig      => $source_config ? {undef => $config_file, default => $source_config},
          destinationconfig => $destination_config ? {undef => $config_file, default => $destination_config},
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
