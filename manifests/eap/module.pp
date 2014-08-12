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
}
