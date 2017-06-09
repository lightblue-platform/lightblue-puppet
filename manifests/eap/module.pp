# == Class: lightblue::eap::module
#
# Configures various lightblue properties files as a JBoss module.
#
# === Parameters
#
# [*mongo_auth_mechanism*]
#
# [*mongo_auth_username*]
#
# [*mongo_auth_password*]
#
# [*mongo_auth_source*]
#
# [*mongo_metadata_readPreference*]
#
# [*mongo_data_readPreference*]
#
# [*hystrix_command_default_execution_isolation_strategy*]
#
# [*hystrix_command_default_execution_isolation_thread_timeoutInMilliseconds*]
#
# [*hystrix_command_default_circuitBreaker_enabled*]
#
# [*hystrix_command_mongodb_execution_isolation_timeoutInMilliseconds*]
#
# [*hystrix_threadpool_mongodb_coreSize*]
#
# [*mongo_servers_cfg*]
#
# [*mongo_ssl*]
#
# [*mongo_maxResultSetSize*]
#
# [*mongo_noCertValidation*]
#
# [*ldap_config*]
#   Hash containing all configuration for the ldap controller.  Optional.
#
# [*rdbms_servers_cfg*]
#
# [*hook_configuration_parsers*]
#
# [*backend_parsers*]
#
# [*property_parsers*]
#
# [*additional_backend_controllers*]
#
# [*data_cors_config*]
#   Hash for configuring cross-origin resource sharing for the data service. All
#   fields are optional, and the presence of an empty hash is enough to enable CORS
#   with default configuration. The field names for the hash are:
#
#   - url_patterns (array)
#   - allowed_origins (array)
#   - allowed_headers (array)
#   - exposed_headers (array)
#   - allow_credentials (boolean)
#   - preflight_max_age (int)
#   - enable_logging (boolean)
#
#   For details of what these fields control, see lightblue::service::cors::configure.
#
# [*metadata_cors_config*]
#   Hash for configuring cross-origin resource sharing for the metadata service. All
#   fields are optional, and the presence of an empty hash is enough to enable CORS
#   with default configuration. The field names for the hash are:
#
#   - url_patterns (array)
#   - allowed_origins (array)
#   - allowed_headers (array)
#   - exposed_headers (array)
#   - allow_credentials (boolean)
#   - preflight_max_age (int)
#   - enable_logging (boolean)
#
#   For details of what these fields control, see lightblue::service::cors::configure.
#
# [*locking*]
#  Configures the locking extension
#
#   Example:
#        [
#          {
#            "domain":"MyDomainName",
#            "datasource":"datasource",
#            "collection":"collectionName"
#          },
#          ...
#        ]
#
# [*plugins*]
#  List of external jar file or directories of jars.
#
# === Variables
#
# None
#
# === Examples
#
class lightblue::eap::module (
    $mongo_auth_mechanism,
    $mongo_auth_username,
    $mongo_auth_password,
    $mongo_auth_source,
    $hystrix_command_default_execution_isolation_strategy = 'THREAD',
    $hystrix_command_default_execution_isolation_thread_timeoutInMilliseconds = 60000,
    $hystrix_command_default_circuitBreaker_enabled = false,
    $hystrix_command_mongodb_execution_isolation_timeoutInMilliseconds = 50000,
    $hystrix_threadpool_mongodb_coreSize = 30,
    $hystrix_execution_timeout_enabled = undef,
    $mongo_servers_cfg = undef,
    $mongo_ssl = true,
    $mongo_maxResultSetSize = 15000,
    $mongo_noCertValidation = false,
    $mongo_metadata_readPreference = 'primary',
    $mongo_data_readPreference = 'primary',
    $ldap_config = undef,
    $rdbms_servers_cfg = undef,
    $hook_configuration_parsers = '',
    $backend_parsers = undef,
    $property_parsers = undef,
    $additional_backend_controllers = undef,
    $data_cors_config=undef,
    $metadata_cors_config=undef,
    $locking = undef,
    $plugins = undef,
    $memoryIndexThreshold = undef,
)
{
    include lightblue::eap
    $directory = '/usr/share/jbossas/modules/com/redhat/lightblue/main'

    # Setup the properties directory
    file { [ '/usr/share/jbossas/modules/com',
        '/usr/share/jbossas/modules/com/redhat',
        '/usr/share/jbossas/modules/com/redhat/lightblue',
        $directory ]:
        ensure  => 'directory',
        owner   => 'jboss',
        group   => 'jboss',
        mode    => '0755',
        require => Package[$lightblue::eap::package_name],
    }

    # class to deploy datasources.json
    class {'lightblue::eap::module::datasources':
        directory                     => $directory,
        mongo_auth_mechanism          => $mongo_auth_mechanism,
        mongo_auth_username           => $mongo_auth_username,
        mongo_auth_password           => $mongo_auth_password,
        mongo_auth_source             => $mongo_auth_source,
        mongo_metadata_readPreference => $mongo_metadata_readPreference,
        mongo_data_readPreference     => $mongo_data_readPreference,
        mongo_servers_cfg             => $mongo_servers_cfg,
        mongo_maxResultSetSize        => $mongo_maxResultSetSize,
        mongo_ssl                     => $mongo_ssl,
        mongo_noCertValidation        => $mongo_noCertValidation,
        ldap_config                   => $ldap_config,
        rdbms_servers_cfg             => $rdbms_servers_cfg,
    }

    # class to deploy lightblue-metadata.json
    class {'lightblue::eap::module::metadata':
        directory                  => $directory,
        hook_configuration_parsers => $hook_configuration_parsers,
        backend_parsers            => $backend_parsers,
        property_parsers           => $property_parsers,
        metadata_roles             => $lightblue::eap::module::metadata::metadata_roles,
    }

    # class to deploy lightblue-external-resources.json
    class {'lightblue::eap::module::plugins':
      directory => $directory,
      plugins   => $plugins
    }

    if $data_cors_config != undef {
        lightblue::service::cors::configure { "${directory}/lightblue-crud-cors.json":
            url_patterns      => $data_cors_config[url_patterns],
            allowed_origins   => $data_cors_config[allowed_origins],
            allowed_methods   => $data_cors_config[allowed_methods],
            allowed_headers   => $data_cors_config[allowed_headers],
            exposed_headers   => $data_cors_config[exposed_headers],
            allow_credentials => $data_cors_config[allow_credentials],
            preflight_max_age => $data_cors_config[preflight_max_age],
            enable_logging    => $data_cors_config[enable_logging],
            require           => File[$directory],
        }
    }

    if $metadata_cors_config != undef {
        lightblue::service::cors::configure { "${directory}/lightblue-metadata-cors.json":
            url_patterns      => $metadata_cors_config[url_patterns],
            allowed_origins   => $metadata_cors_config[allowed_origins],
            allowed_methods   => $metadata_cors_config[allowed_methods],
            allowed_headers   => $metadata_cors_config[allowed_headers],
            exposed_headers   => $metadata_cors_config[exposed_headers],
            allow_credentials => $metadata_cors_config[allow_credentials],
            preflight_max_age => $metadata_cors_config[preflight_max_age],
            enable_logging    => $metadata_cors_config[enable_logging],
            require           => File[$directory],
        }
    }

    # Property files
    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/module.xml':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/module.xml.erb'),
        require => File[$directory],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/config.properties':
        mode    => '0550',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/config.properties.erb'),
        require => File[$directory],
    }

    if !$mongo_noCertValidation {
        # deploy truststore and mongossl
        include lightblue::eap::truststore
        include lightblue::eap::mongossl
    }

    # both configs for crud and metadata are required for each service to work

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-crud.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-crud.json.erb'),
        require => File[$directory],
    }
    # Ensure deprecated settings are removed from filesystem
    file { [ '/usr/share/jbossas/modules/com/redhat/lightblue/main/appconfig.properties',
        '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-client.properties',
        '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-cilent.properties',
        '/usr/share/jbossas/modules/com/redhat/lightblue/main/cacert.pem',
        '/usr/share/jbossas/modules/com/redhat/lightblue/main/lb-metadata-mgmt.pkcs12']:
        ensure => absent,
    }
}
