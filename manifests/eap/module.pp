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
    $mongo_servers_cfg = undef,
    $mongo_ssl = true,
    $mongo_noCertValidation = false,
    $rdbms_servers_cfg = undef,
    $hook_configuration_parsers = '',
    $backend_parsers = undef,
    $property_parsers = undef,
    $additional_backend_controllers = undef,
    $mgmt_app_service_URI,
    $mgmt_app_use_cert_auth,
    $mgmt_app_ca_file_path,
    $mgmt_app_cert_file_path,
    $mgmt_app_cert_password,
    $mgmt_app_cert_alias,
    $client_ca_source,
    $client_cert_source,
    $metadata_roles=undef,
)
{
    $directory = '/usr/share/jbossas/modules/com/redhat/lightblue/main'

    # Setup the properties directory
    file { [ '/usr/share/jbossas/modules/com',
        '/usr/share/jbossas/modules/com/redhat',
        '/usr/share/jbossas/modules/com/redhat/lightblue',
        $directory ]:
        ensure   => 'directory',
        owner    => 'jboss',
        group    => 'jboss',
        mode     => '0755',
        require  => Package[$lightblue::eap::package_name],
    }

    # class to deploy datasources.json
    class {'lightblue::eap::module::datasources':
        directory               => $directory,
        mongo_auth_mechanism    => $mongo_auth_mechanism,
        mongo_auth_username     => $mongo_auth_username,
        mongo_auth_password     => $mongo_auth_password,
        mongo_auth_source       => $mongo_auth_source,
        mongo_servers_cfg       => $mongo_servers_cfg,
        mongo_ssl               => $mongo_ssl,
        mongo_noCertValidation  => $mongo_noCertValidation,
        rdbms_servers_cfg       => $rdbms_servers_cfg,
    }

    # class to deploy lightblue-metadata.json
    class {'lightblue::eap::module::metadata':
        directory                   => $directory,
        hook_configuration_parsers  => $hook_configuration_parsers,
        backend_parsers             => $backend_parsers,
        property_parsers            => $property_parsers,
        metadata_roles              => $metadata_roles,
    }

    # Property files
    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/module.xml':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/module.xml.erb'),
        notify  => Service['jbossas'],
        require => File[$directory],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/appconfig.properties':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/appconfig.properties.erb'),
        notify  => Service['jbossas'],
        require => File[$directory],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-client.properties':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/appconfig.properties.erb'),
        notify  => Service['jbossas'],
        require => File[$directory],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/config.properties':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/config.properties.erb'),
        notify  => Service['jbossas'],
        require => File[$directory],
    }

    if !$mongo_noCertValidation {
        # deploy cacert and mongossl
        include lightblue::cacert
        include lightblue::eap::mongossl
    }

    # both configs for crud and metadata are required for each service to work

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-crud.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-crud.json.erb'),
        notify  => Service['jbossas'],
        require => File[$directory],
    }

    # client-cert config
    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/cacert.pem':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        links   => 'follow',
        source  => $client_ca_source,
        notify  => Service['jbossas'],
        require => File[$directory],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lb-metadata-mgmt.pkcs12':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        links   => 'follow',
        source  => $client_cert_source,
        notify  => Service['jbossas'],
        require => File[$directory],
    }

}
