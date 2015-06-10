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
# $primary_config_file               - (required) Lightblue Client configuration file for the Mongo backend used for scheduling jobs.
#                                      Will also be used for source/destination configurations if they are not provided.
# $primary_client_metadata_uri       - see lightblue::client::configure
# $primary_client_data_uri           - see lightblue::client::configure
# $primary_client_use_cert_auth      - see lightblue::client::configure
# $primary_client_ca_file_path       - (optional) ca file path
# $primary_client_ca_source          - (optional) source for ca file.
# $primary_client_cert_file_path     - (optional) cert file path
# $primary_client_cert_source        - (optional) source for cert file.
# $primary_client_cert_password      - see lightblue::client::configure
# $primary_client_cert_alias         - see lightblue::client::configure
#
# $is_source_same_as_primary         - Indicates if the source lightblue instance is the same as the primary. Defaults to true.
# $source_client_metadata_uri        - see lightblue::client::configure
# $source_client_data_uri            - see lightblue::client::configure
# $source_client_use_cert_auth       - see lightblue::client::configure
# $source_client_ca_file_path        - (optional) ca file path
# $source_client_ca_source           - (optional) source for ca file.
# $source_client_cert_file_path      - (optional) cert file path
# $source_client_cert_source         - (optional) source for cert file.
# $source_client_cert_password       - see lightblue::client::configure
# $source_client_cert_alias          - see lightblue::client::configure
#
# $is_destination_same_as_primary    - Indicates if the destination lightblue instance is the same as the primary. Defaults to true.
# $destination_client_metadata_uri   - see lightblue::client::configure
# $destination_client_data_uri       - see lightblue::client::configure
# $destination_client_use_cert_auth  - see lightblue::client::configure
# $destination_client_ca_file_path   - (optional) ca file path
# $destination_client_ca_source      - (optional) source for ca file.
# $destination_client_cert_file_path - (optional) cert file path
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
    $migrator_home_dir = '/usr/share/lightblue-migrator',
    $migrator_config_dir = '/etc/lightblue-migrator',
    $migrator_log_dir = '/var/log/lightblue-migrator',
    $generate_log4j = false,
    $java_home = undef,
    $migrator_package_name = 'lightblue-migrator',
    $jar_path = '/usr/share/lightblue-migrator/lightblue-migrator-*.jar',
    $service_log_name = 'console.log',
    $hostname = '$(hostname)',
    $serviceJvmOptions = [],
    $checker_name,

    #primary lightblue client to be used as migrator backend
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
    $is_source_same_as_primary = true,
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
    $is_destination_same_as_primary = true,
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
    } ->
    file { $service_log_path:
      ensure => 'file',
      owner  => $service_owner,
      group  => $service_group,
      mode   => '0644',
    } ->
    file { "${migrator_home_dir}/log":
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
      mode   => '0755',
      before => Service[$migrator_service_name],
    } ->
    file { "${migrator_home_dir}/conf":
      ensure  => 'link',
      target  => $migrator_config_dir,
      before  => Service[$migrator_service_name],
      require => File[$migrator_home_dir],
    }

    #configure primary lightblue instance
    if($primary_client_use_cert_auth){
      #ensure the primary client ca exists
      if($primary_client_ca_source){
        if($primary_client_ca_file_path){
          $primary_client_ca = $primary_client_ca_file_path
        }
        else{
          $primary_client_ca = "${migrator_config_dir}/primary-lightblue.pem"
        }

        file { $primary_client_ca:
          mode    => '0644',
          owner   => $service_owner,
          group   => $service_group,
          links   => 'follow',
          source  => $primary_client_ca_source,
          require => File[$migrator_config_dir],
          notify  => [Service[$migrator_service_name]],
        }
      }
      else{
        if(!$primary_client_ca_file_path){
          fail('If using your own primary migrator ca then the $primary_client_ca_file_path must be provided')
        }

        $primary_client_ca = $primary_client_ca_file_path
      }

      #ensure the primary client cert exists
      if($primary_client_cert_source){
        if($primary_client_cert_file_path){
          $primary_client_cert = $primary_client_cert_file_path
        }
        else{
          $primary_basename = basename($primary_client_cert_source)
          $primary_client_cert = "${migrator_config_dir}/${primary_basename}"
        }

        file { $primary_client_cert:
          mode    => '0644',
          owner   => $service_owner,
          group   => $service_group,
          links   => 'follow',
          source  => $primary_client_cert_source,
          require => File[$migrator_config_dir],
          notify  => [Service[$migrator_service_name]],
        }
      }
      else{
        if(!$primary_client_cert_file_path){
          fail('If using your own primary migrator cert then the $primary_client_cert_file_path must be provided.')
        }

        $primary_client_cert = $primary_client_cert_file_path
      }
    }
    else {
      $primary_client_ca = undef
      $primary_client_cert = undef
    }

    $primary_config_file = "${migrator_config_dir}/primary-lightblue-client.properties"
    lightblue::client::configure { $primary_config_file:
      owner                   => $service_owner,
      group                   => $service_group,
      lbclient_metadata_uri   => $primary_client_metadata_uri,
      lbclient_data_uri       => $primary_client_data_uri,
      lbclient_use_cert_auth  => $primary_client_use_cert_auth,
      lbclient_ca_file_path   => $primary_client_ca,
      lbclient_cert_file_path => $primary_client_cert,
      lbclient_cert_password  => $primary_client_cert_password,
      lbclient_cert_alias     => $primary_client_cert_alias,
      require                 => File[$migrator_config_dir],
      notify                  => [Service[$migrator_service_name]],
    }

    #configure source lightblue instance
    if($is_source_same_as_primary){
      $source_config_file = $primary_config_file
    }
    else {
      if !$source_client_metadata_uri or !$source_client_data_uri {
        fail('If defining a source_config, then you must also define data and metadata urls for it.')
      }

      if($source_client_use_cert_auth){
        #ensure the source client ca exists
        if($source_client_ca_source){
          if($source_client_ca_file_path){
            $source_client_ca = $source_client_ca_file_path
          }
          else{
            $source_client_ca = "${migrator_config_dir}/source-lightblue.pem"
          }

          file { $source_client_ca:
            mode    => '0644',
            owner   => $service_owner,
            group   => $service_group,
            links   => 'follow',
            source  => $source_client_ca_source,
            require => File[$migrator_config_dir],
            notify  => [Service[$migrator_service_name]],
          }
        }
        else{
          if(!$source_client_ca_file_path){
            fail('If using your own source ca then the $source_client_ca_file_path must be provided.')
          }

          $source_client_ca = $source_client_ca_file_path
        }

        #ensure the source client cert exists
        if($source_client_cert_source){
          if($source_client_cert_file_path){
            $source_client_cert = $source_client_cert_file_path
          }
          else{
            $source_basename = basename($source_client_cert_source)
            $source_client_cert = "${migrator_config_dir}/${source_basename}"
          }

          file { $source_client_cert:
            mode    => '0644',
            owner   => $service_owner,
            group   => $service_group,
            links   => 'follow',
            source  => $source_client_cert_source,
            require => File[$migrator_config_dir],
            notify  => [Service[$migrator_service_name]],
          }
        }
        else{
          if(!$source_client_cert_file_path){
            fail('If using your own source cert then the $source_client_cert_file_path must be provided.')
          }

          $source_client_cert = $source_client_cert_file_path
        }
      }
      else {
        $source_client_ca = undef
        $source_client_cert = undef
      }

      $source_config_file = "${migrator_config_dir}/source-lightblue-client.properties"
      lightblue::client::configure { $source_config_file:
        owner                   => $service_owner,
        group                   => $service_group,
        lbclient_metadata_uri   => $source_client_metadata_uri,
        lbclient_data_uri       => $source_client_data_uri,
        lbclient_use_cert_auth  => $source_client_use_cert_auth,
        lbclient_ca_file_path   => $source_client_ca,
        lbclient_cert_file_path => $source_client_cert,
        lbclient_cert_password  => $source_client_cert_password,
        lbclient_cert_alias     => $source_client_cert_alias,
        require                 => File[$migrator_config_dir],
        notify                  => [Service[$migrator_service_name]],
      }
    }

    #configure destination lightblue instance
    if($is_destination_same_as_primary){
      $destination_config_file = $primary_config_file
    }
    else {
      if !$destination_client_metadata_uri or !$destination_client_data_uri {
        fail('If defining a destination_config, then you must also define data and metadata urls for it.')
      }
      if($destination_client_use_cert_auth){
        #ensure the destination client ca exists
        if($destination_client_ca_source){
          if($destination_client_ca_file_path){
            $destination_client_ca = $destination_client_ca_file_path
          }
          else{
            $destination_client_ca = "${migrator_config_dir}/destination-lightblue.pem"
          }

          file { $destination_client_ca:
            mode    => '0644',
            owner   => $service_owner,
            group   => $service_group,
            links   => 'follow',
            source  => $destination_client_ca_source,
            require => File[$migrator_config_dir],
            notify  => [Service[$migrator_service_name]],
          }
        }
        else{
          if(!$destination_client_ca_file_path){
            fail('If using your own destination ca then the $destination_client_ca_file_path must be provided.')
          }

          $destination_client_ca = $destination_client_ca_file_path
        }

        #ensure the destination client cert exists
        if($destination_client_cert_source){
          if($destination_client_cert_file_path){
            $destination_client_cert = $destination_client_cert_file_path
          }
          else{
            $destination_basename = basename($destination_client_cert_source)
            $destination_client_cert = "${migrator_config_dir}/${destination_basename}"
          }

          file { $destination_client_cert:
            mode    => '0644',
            owner   => $service_owner,
            group   => $service_group,
            links   => 'follow',
            source  => $destination_client_cert_source,
            require => File[$migrator_config_dir],
            notify  => [Service[$migrator_service_name]],
          }
        }
        else{
          if(!$destination_client_cert_file_path){
            fail('If using your own destination cert then the $destination_client_cert_file_path must be provided.')
          }

          $destination_client_cert = $destination_client_cert_file_path
        }
      }
      else {
        $destination_client_ca = undef
        $destination_client_cert = undef
      }

      $destination_config_file = "${migrator_config_dir}/destination-lightblue-client.properties"
      lightblue::client::configure { $destination_config_file:
        owner                   => $service_owner,
        group                   => $service_group,
        lbclient_metadata_uri   => $destination_client_metadata_uri,
        lbclient_data_uri       => $destination_client_data_uri,
        lbclient_use_cert_auth  => $destination_client_use_cert_auth,
        lbclient_ca_file_path   => $destination_client_ca,
        lbclient_cert_file_path => $destination_client_cert,
        lbclient_cert_password  => $destination_client_cert_password,
        lbclient_cert_alias     => $destination_client_cert_alias,
        require                 => File[$migrator_config_dir],
        notify                  => [Service[$migrator_service_name]],
      }
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
    } ->
    package { $migrator_package_name:
      ensure => $migrator_version,
      notify => [Service[$migrator_service_name]],
    } ->
    class { 'lightblue::application::migrator::daemon':
      jsvc_version        => $jsvc_version,
      owner               => $service_owner,
      group               => $service_group,
      service_name        => $migrator_service_name,
      service_out_logfile => $service_log_path,
      service_err_logfile => $service_log_path,
      java_home           => $java_home,
      jar_path            => $jar_path,
      mainClass           => 'com.redhat.lightblue.migrator.Main',
      arguments           => {
        name              => $checker_name,
        hostname          => $hostname,
        config            => $primary_config_file,
      },
      jvmOptions          => union($log4j_jvm_options, $serviceJvmOptions),
    } ~>
    service { $migrator_service_name:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }

}
