class lightblue::eap::module {
    # get all hystrix config variables
    $hystrix_command_default_execution_isolation_strategy = hiera('lightblue::hystrix::command::default::execution_isolation_strategy', 'THREAD')
    $hystrix_command_default_execution_isolation_thread_timeoutInMilliseconds = hiera('lightblue::hystrix::command::default::execution_isolation_thread_timeoutInMilliseconds', 60000)
    $hystrix_command_default_circuitBreaker_enabled = hiera('lightblue::hystrix::command::default::circuitBreaker_enabled', false)
    $hystrix_command_mongodb_execution_isolation_timeoutInMilliseconds = hiera('lightblue::hystrix::command::mongodb::execution_isolation_timeoutInMilliseconds', 50000)
    $hystrix_threadpool_mongodb_coreSize = hiera('lightblue::hystrix::threadpool::mongodb_coreSize', 30)

    $mongo_server_host = hiera('lightblue::mongo::server_host', undef)
    $mongo_server_port = hiera('lightblue::mongo::server_port', undef)
    $mongo_servers_cfg = hiera('lightblue::mongo::servers', undef)
    $mongo_ssl = hiera('lightblue::mongo::ssl', true)
    $mongo_noCertValidation = hiera('lightblue::mongo::noCertValidation', false)
    $mongo_auth_mechanism = hiera('lightblue::mongo::auth::mechanism')
    $mongo_auth_username = hiera('lightblue::mongo::auth::username')
    $mongo_auth_password = hiera('lightblue::mongo::auth::password')
    $mongo_auth_source = hiera('lightblue::mongo::auth::source')

    # Setup the properties directory
    file { [ '/usr/share/jbossas/modules/com',
        '/usr/share/jbossas/modules/com/redhat',
        '/usr/share/jbossas/modules/com/redhat/lightblue',
        '/usr/share/jbossas/modules/com/redhat/lightblue/main']:
        ensure   => 'directory',
        owner    => 'jboss',
        group    => 'jboss',
        mode     => '0755',
        require  => Package['jbossas-standalone'],
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

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/datasources.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/datasources.json.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }
}
