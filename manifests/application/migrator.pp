# == Class: lightblue::application::migrator
#
# Deploys lightblue migrator service.
#
# === Parameters
#
# $service_owner                     - Owner of service and related files. Defaults to root.
# $service_group                     - Group of service and related files. Defaults to root.
# $migrator_version                  - Version of consistency-checker rpm to install. Defaults to latest.
# $generate_log4j                    - Boolean indicating if a log4j.properties file should be generated. Defaults to false
# $jsvc_version                      - Version of the jsvc package to install. Defaults to latest.
# $migrator_home_dir                 - Absolute home directory of the migrator installation. Defaults to '/usr/share/lightblue-migrator'.
# $migrator_config_dir               - Absolute config directory. Defaults to '/etc/lightblue-migrator'.
# $migrator_log_dir                  - Absolute log directory. Defaults to '/var/log/lightblue-migrator'.
# $java_home                         - (optional) Specify the java home directory. Defaults to JAVA_HOME.
# $jar_path                          - (optional) Specify the path to the jar file to be wrapped in the service.
# $service_log_name                  - File name for jsvc to log stdout/stderr message too.
# $checker_name                      - Name of this consistency-checker.
# $hostname                          - Hostname to pass into consistency-checker. Defaults to $(hostname)
# $serviceJvmOptions                 - JVM options to pass into the service. Defaults to {}. -X will be appended to keys.
#
# $primary_client_metadata_uri       - see lightblue::client::configure
# $primary_client_data_uri           - see lightblue::client::configure
# $primary_client_use_cert_auth      - see lightblue::client::configure
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
    $checker_name,
    #primary lightblue client to be used as migrator backend
    $primary_client_certificate_name,
    $primary_client_certificate_file,
    $primary_client_certificate_password,
    $primary_client_certificate_source,
    $primary_client_metadata_uri,
    $primary_client_data_uri,
    $service_owner = 'root',
    $service_group = 'root',
    $migrator_version = 'latest',
    $jsvc_version = 'latest',
    $migrator_home_dir = '/usr/share/lightblue-migrator',
    $migrator_config_dir = '/etc/lightblue-migrator',
    $migrator_log_dir = '/var/log/lightblue-migrator',
    $generate_log4j = false,
    $java_home = undef,
    $migrator_package_name = 'lightblue-migrator',
    $jar_path = '/usr/share/lightblue-migrator/lightblue-migrator-*.jar',
    $service_log_name = 'console.log',
    $hostname = '$(hostname)',
    $service_jvm_options = [],
    $primary_client_use_cert_auth = false,
    $primary_client_ca_certificates = undef,
){
    require lightblue::yumrepo::lightblue
    require lightblue::java

    $migrator_service_name = 'migrator-service'

    #migrator home directory
    file { $migrator_home_dir:
      ensure => 'directory',
      owner  => $service_owner,
      group  => $service_group,
      mode   => '0755',
      before => Service[$migrator_service_name],
    }

    #migrator logging directory
    $service_log_path = "${migrator_log_dir}/${service_log_name}"
    file { $migrator_log_dir:
      ensure => 'directory',
      owner  => $service_owner,
      group  => $service_group,
      mode   => '0755',
      before => Service[$migrator_service_name],
    } -> file { $service_log_path:
      ensure => 'file',
      owner  => $service_owner,
      group  => $service_group,
      mode   => '0644',
    } -> file { "${migrator_home_dir}/log":
      ensure  => 'link',
      target  => $migrator_log_dir,
      before  => Service[$migrator_service_name],
      require => File[$migrator_home_dir],
    }

    #migrator config directory
    file { $migrator_config_dir:
      ensure => 'directory',
      owner  => $service_owner,
      group  => $service_group,
      mode   => '0440',
      before => Service[$migrator_service_name],
    } -> file { "${migrator_home_dir}/conf":
      ensure  => 'link',
      target  => $migrator_config_dir,
      before  => Service[$migrator_service_name],
      require => File[$migrator_home_dir],
    }

    $certificate_file_defaults = {
      file_path => $migrator_config_dir,
      mode      => '0440',
      owner     => $service_owner,
      group     => $service_group,
      links     => 'follow',
      notify    => [Service[$migrator_service_name]],
    }

    #configure primary lightblue instance
    if($primary_client_use_cert_auth){
      #ensure the primary client ca exists
      if(!$primary_client_ca_certificates) {
        fail('At least 1 primary ca must be provided')
      }
      create_resources(lightblue::client::cert_file, $primary_client_ca_certificates, $certificate_file_defaults)
    }

    lightblue::client::client_cert { $primary_client_certificate_name:
      file_path            => $migrator_config_dir,
      file                 => $primary_client_certificate_file,
      password             => $primary_client_certificate_password,
      source               => $primary_client_certificate_source,
      data_service_uri     => $primary_client_data_uri,
      metadata_service_uri => $primary_client_metadata_uri,
      use_cert_auth        => $primary_client_use_cert_auth,
      ca_certificates      => $primary_client_ca_certificates,
      owner                => $service_owner,
      group                => $service_group,
      use_physical_file    => true,
      notify               => [Service[$migrator_service_name]],
    }

    if($generate_log4j){
      class{ 'lightblue::application::migrator::log4j':
        config_dir => $migrator_config_dir,
        log_dir    => $migrator_log_dir,
        owner      => $service_owner,
        group      => $service_group,
        require    => File[$migrator_config_dir],
      }
      $log4j_jvm_options = ["Dlog4j.configuration=file:${::lightblue::application::migrator::log4j::log4j_config_file}"]
    }
    else{
      $log4j_jvm_options = []
    }

    package {'lightblue-migrator-consistency-checker':
      #old package for the migrator, it should be uninstalled.
      ensure => 'absent'
    } -> package { $migrator_package_name:
      ensure => $migrator_version,
      notify => [Service[$migrator_service_name]],
    } -> class { 'lightblue::application::migrator::daemon':
      jsvc_version        => $jsvc_version,
      owner               => $service_owner,
      group               => $service_group,
      service_name        => $migrator_service_name,
      service_out_logfile => $service_log_path,
      service_err_logfile => $service_log_path,
      java_home           => $java_home,
      jar_path            => $jar_path,
      main_class          => 'com.redhat.lightblue.migrator.Main',
      arguments           => {
        name     => $checker_name,
        hostname => $hostname,
        config   => "${migrator_config_dir}/${primary_client_certificate_name}.properties",
      },
      jvm_options         => union($log4j_jvm_options, $service_jvm_options),
    } ~> service { $migrator_service_name:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }

}
