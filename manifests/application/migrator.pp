# == Class: lightblue::application::migrator
#
# Deploys lightblue migrator service.
#
# === Parameters
#
# $service_owner                     - Owner of service and related files. Defaults to root.
# $service_group                     - Group of service and related files. Defaults to root.
# $migrator_version                  - Version of consistency-checker rpm to install. Defaults to latest.
# $jsvc_version                      - Version of the jsvc package to install. Defaults to latest.
# $java_home                         - (optional) Specify the java home directory. Defaults to JAVA_HOME.
# $jar_path                          - (optional) Specify the path to the jar file to be wrapped in the service.
# $service_log_file                  - Path to log out/err message too.
# $checker_name                      - Name of this consistency-checker.
# $hostname                          - Hostname to pass into consistency-checker. Defaults to $(hostname)
# $configuration_version             - Configuration version to pass into consistency-checker.
# $job_version                       - Job version to pass into consistency-checker.
# $serviceJvmOptions                 - JVM options to pass into the service. Defaults to {}. -X will be appended to keys.
#
# $primary_config_file               - (required) Lightblue Client configuration file for the Mongo backend used for scheduling jobs.
#                                      Will also be used for source/destination configurations if they are not provided.
# $primary_client_metadata_uri       - see lightblue::client::configure
# $primary_client_data_uri           - see lightblue::client::configure
# $primary_client_use_cert_auth      - see lightblue::client::configure
# $primary_client_ca_file_path       - see lightblue::client::configure
# $primary_client_ca_source          - (optional) source for ca file.
# $primary_client_cert_file_path     - see lightblue::client::configure
# $primary_client_cert_source        - (optional) source for cert file.
# $primary_client_cert_password      - see lightblue::client::configure
# $primary_client_cert_alias         - see lightblue::client::configure
#
# $source_config                     - Source lightblue client configuration file. Defaults to $config_file.
# $source_client_metadata_uri        - see lightblue::client::configure
# $source_client_data_uri            - see lightblue::client::configure
# $source_client_use_cert_auth       - see lightblue::client::configure
# $source_client_ca_file_path        - see lightblue::client::configure
# $source_client_ca_source           - (optional) source for ca file.
# $source_client_cert_file_path      - see lightblue::client::configure
# $source_client_cert_source         - (optional) source for cert file.
# $source_client_cert_password       - see lightblue::client::configure
# $source_client_cert_alias          - see lightblue::client::configure
#
# $destination_config                - Destination lightblue client configuration file. Defaults to $config_file.
# $destination_client_metadata_uri   - see lightblue::client::configure
# $destination_client_data_uri       - see lightblue::client::configure
# $destination_client_use_cert_auth  - see lightblue::client::configure
# $destination_client_ca_file_path   - see lightblue::client::configure
# $destination_client_ca_source      - (optional) source for ca file.
# $destination_client_cert_file_path - see lightblue::client::configure
# $destination_client_cert_source    - (optional) source for cert file.
# $destination_client_cert_password  - see lightblue::client::configure
# $destination_client_cert_alias     - see lightblue::client::configure
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
    $service_owner = 'root',
    $service_group = 'root',
    $migrator_version = 'latest',
    $jsvc_version = 'latest',
    $java_home = undef,
    $jar_path = '/var/lib/jbossas/standalone/deployments/lightblue-migrator-consistency-checker-*.jar',
    $service_log_file = 'migrator.log',
    $hostname = '$(hostname)',
    $serviceJvmOptions = {},
    $checker_name,
    $job_version,
    $configuration_version,

    #primary lightblue client to be used as migrator backend
    $primary_config_file = 'lightblue-client.properties',
    $primary_client_metadata_uri,
    $primary_client_data_uri,
    $primary_client_use_cert_auth = false,
    $primary_client_ca_file_path = undef,
    $primary_client_ca_source = undef,
    $primary_client_cert_file_path = undef,
    $primary_client_cert_source = undef,
    $primary_client_cert_password = undef,
    $primary_client_cert_alias = undef,

    #(optional) source lightblue client to pull data from
    $source_config = undef,
    $source_client_metadata_uri = undef,
    $source_client_data_uri = undef,
    $source_client_use_cert_auth = false,
    $source_client_ca_file_path = undef,
    $source_client_ca_source = undef,
    $source_client_cert_file_path = undef,
    $source_client_cert_source = undef,
    $source_client_cert_password = undef,
    $source_client_cert_alias = undef,

    #(optional) destination lightblue client to push data too
    $destination_config = undef,
    $destination_client_metadata_uri = undef,
    $destination_client_data_uri = undef,
    $destination_client_use_cert_auth = false,
    $destination_client_ca_file_path = undef,
    $destination_client_ca_source = undef,
    $destination_client_cert_file_path = undef,
    $destination_client_cert_source = undef,
    $destination_client_cert_password = undef,
    $destination_client_cert_alias = undef,
){
    require lightblue::yumrepo::lightblue
    require lightblue::java

    $migrator_service_name = 'migrator-service'
    $migrator_package_name = 'lightblue-migrator-consistency-checker'
    $source_config_file = $source_config ? {undef => $primary_config_file, default => $source_config}
    $destination_config_file = $destination_config ? {undef => $primary_config_file, default => $destination_config}

    package { $migrator_package_name:
      ensure  => $migrator_version,
      notify  => [Service[$migrator_service_name]],
    }

    if($primary_client_use_cert_auth and $primary_client_ca_source) {
      if(!$primary_client_ca_file_path){
        fail('Must provide $primary_client_ca_file_path in order to deploy ca file.')
      }

      file { $primary_client_ca_file_path:
        mode    => '0644',
        owner   => $service_owner,
        group   => $service_group,
        links   => 'follow',
        source  => $primary_client_ca_source,
        notify  => [Service[$migrator_service_name]],
      }
    }

    if($primary_client_use_cert_auth and $primary_client_cert_source){
      if(!$primary_client_ca_file_path){
        fail('Must provide $primary_client_cert_file_path in order to deploy cert file.')
      }

      file { $primary_client_cert_file_path:
        mode    => '0644',
        owner   => $service_owner,
        group   => $service_group,
        links   => 'follow',
        source  => $primary_client_cert_source,
        notify  => [Service[$migrator_service_name]],
      }
    }

    lightblue::client::configure { $primary_config_file:
      owner                   => $service_owner,
      group                   => $service_group,
      lbclient_metadata_uri   => $primary_client_metadata_uri,
      lbclient_data_uri       => $primary_client_data_uri,
      lbclient_use_cert_auth  => $primary_client_use_cert_auth,
      lbclient_ca_file_path   => $primary_client_ca_file_path,
      lbclient_cert_file_path => $primary_client_cert_file_path,
      lbclient_cert_password  => $primary_client_cert_password,
      lbclient_cert_alias     => $primary_client_cert_alias,
      notify                  => [Service[$migrator_service_name]],
    }

    if($source_config_file != $primary_config_file){
      if !$source_client_metadata_uri or !$source_client_data_uri {
        fail('If defining a source_config, then you must also define data and metadata urls for it.')
      }

      if($source_client_use_cert_auth and $source_client_ca_source) {
        if(!$source_client_ca_file_path){
          fail('Must provide $source_client_ca_file_path in order to deploy source ca file.')
        }

        file { $source_client_ca_file_path:
          mode    => '0644',
          owner   => $service_owner,
          group   => $service_group,
          links   => 'follow',
          source  => $source_client_ca_source,
          notify  => [Service[$migrator_service_name]],
        }
      }

      if($source_client_use_cert_auth and $source_client_cert_source) {
        if(!$source_client_cert_file_path){
          fail('Must provide $source_client_cert_file_path in order to deploy source cert file.')
        }

        file { $source_client_cert_file_path:
          mode    => '0644',
          owner   => $service_owner,
          group   => $service_group,
          links   => 'follow',
          source  => $source_client_cert_source,
          notify  => [Service[$migrator_service_name]],
        }
      }

      lightblue::client::configure { $source_config_file:
        owner                   => $service_owner,
        group                   => $service_group,
        lbclient_metadata_uri   => $source_client_metadata_uri,
        lbclient_data_uri       => $source_client_data_uri,
        lbclient_use_cert_auth  => $source_client_use_cert_auth,
        lbclient_ca_file_path   => $source_client_ca_file_path,
        lbclient_cert_file_path => $source_client_cert_file_path,
        lbclient_cert_password  => $source_client_cert_password,
        lbclient_cert_alias     => $source_client_cert_alias,
        notify                  => [Service[$migrator_service_name]],
      }
    }

    if($destination_config_file != $primary_config_file){
      if !$destination_client_metadata_uri or !$destination_client_data_uri {
        fail('If defining a destination_config, then you must also define data and metadata urls for it.')
      }

      if($destination_client_use_cert_auth and $destination_client_ca_source){
        if(!$destination_client_ca_file_path){
          fail('Must provide $destination_client_ca_file_path in order to deploy destination ca file .')
        }

        file { $destination_client_ca_file_path:
          mode    => '0644',
          owner   => $service_owner,
          group   => $service_group,
          links   => 'follow',
          source  => $destination_client_ca_source,
          notify  => [Service[$migrator_service_name]],
        }
      }

      if($destination_client_use_cert_auth and $destination_client_cert_source){
        if(!$destination_client_cert_file_path){
          fail('Must provide $destination_client_cert_file_path in order to deploy destination cert file.')
        }

        file { $destination_client_cert_file_path:
          mode    => '0644',
          owner   => $service_owner,
          group   => $service_group,
          links   => 'follow',
          source  => $destination_client_cert_source,
          notify  => [Service[$migrator_service_name]]
        }
      }

      lightblue::client::configure { $destination_config_file:
        owner                   => $service_owner,
        group                   => $service_group,
        lbclient_metadata_uri   => $destination_client_metadata_uri,
        lbclient_data_uri       => $destination_client_data_uri,
        lbclient_use_cert_auth  => $destination_client_use_cert_auth,
        lbclient_ca_file_path   => $destination_client_ca_file_path,
        lbclient_cert_file_path => $destination_client_cert_file_path,
        lbclient_cert_password  => $destination_client_cert_password,
        lbclient_cert_alias     => $destination_client_cert_alias,
        notify                  => [Service[$migrator_service_name]],
      }
    }

    file { $service_log_file:
      ensure  => 'file',
      owner   => $service_owner,
      group   => $service_group,
      mode    => '0744',
    } ->
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
        config            => $primary_config_file,
        configversion     => $configuration_version,
        jobversion        => $job_version,
        sourceconfig      => $source_config_file,
        destinationconfig => $destination_config_file,
      },
      jvmOptions          => $serviceJvmOptions,
      require             => [Package[$migrator_package_name]],
    } ~>
    service { $migrator_service_name:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }

}
