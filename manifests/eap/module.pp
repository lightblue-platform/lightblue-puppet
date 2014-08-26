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
    $hook_configuration_parsers = '',
    $mgmt_app_service_URI,
    $mgmt_app_ca_file_path,
    $mgmt_app_cert_file_path,
    $mgmt_app_cert_password,
    $mgmt_app_cert_alias,
    $saml_identity_url,
    $saml_service_url,
    $saml_key_store_url,
    $saml_key_store_pass,
    $saml_signing_key_pass,
    $saml_signing_key_alias,
    $saml_validating_alias_key,
    $saml_validating_alias_value,
)
    inherits lightblue::eap
{

    # Setup the properties directory
    file { [ '/usr/share/jbossas/modules/com',
        '/usr/share/jbossas/modules/com/redhat',
        '/usr/share/jbossas/modules/com/redhat/lightblue',
        '/usr/share/jbossas/modules/com/redhat/lightblue/main']:
        ensure   => 'directory',
        owner    => 'jboss',
        group    => 'jboss',
        mode     => '0755',
        require  => Package[$lightblue::eap::package_name],
      }

    # Property files
    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/module.xml':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/module.xml.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/appconfig.properties':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/appconfig.properties.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/config.properties':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/config.properties.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }

    if !$mongo_noCertValidation {
        # deploy cacert and mongossl
        include lightblue::cacert
        include lightblue::eap::mongossl
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/datasources.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/datasources.json.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }

    # both configs for crud and metadata are required for each service to work

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-crud.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-crud.json.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-metadata.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-metadata.json.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }
}
