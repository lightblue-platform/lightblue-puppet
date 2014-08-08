class lightblue::eap::module
    inherits lightblue::eap
{
    # get all hystrix config variables
    $hystrix_command_default_execution_isolation_strategy = hiera('lightblue::eap::module::hystrix::command::default::execution_isolation_strategy::default', 'THREAD')
    $hystrix_command_default_execution_isolation_thread_timeoutInMilliseconds = hiera('lightblue::eap::module::hystrix::command::default::execution_isolation_thread_timeoutInMilliseconds', 60000)
    $hystrix_command_default_circuitBreaker_enabled = hiera('lightblue::eap::module::hystrix::command::default::circuitBreaker_enabled', false)
    $hystrix_command_mongodb_execution_isolation_timeoutInMilliseconds = hiera('lightblue::eap::module::hystrix::command::mongodb::execution_isolation_timeoutInMilliseconds', 50000)
    $hystrix_threadpool_mongodb_coreSize = hiera('lightblue::eap::module::hystrix::threadpool::mongodb::coreSize', 30)

    $mongo_server_host = hiera('lightblue::eap::module::datastore::mongo::server_host', undef)
    $mongo_server_port = hiera('lightblue::eap::module::datastore::mongo::server_port', undef)
    $mongo_servers_cfg = hiera('lightblue::eap::module::datastore::mongo::servers', undef)
    $mongo_ssl = hiera('lightblue::eap::module::datastore::mongo::ssl', true)
    $mongo_noCertValidation = hiera('lightblue::eap::module::datastore::mongo::disableCertValidation', false)
    $mongo_auth_mechanism = hiera('lightblue::eap::module::datastore::mongo::auth::mechanism')
    $mongo_auth_username = hiera('lightblue::eap::module::datastore::mongo::auth::username')
    $mongo_auth_password = hiera('lightblue::eap::module::datastore::mongo::auth::password')
    $mongo_auth_source = hiera('lightblue::eap::module::datastore::mongo::auth::source')

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
        # deploy cacert
        include lightblue::cacert
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/datasources.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/datasources.json.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }

    file { '/etc/ssl/mongodb.pem':
        ensure      => file,
        content     => hiera('lightblue::mongodb::certificate'),
        owner       => 'mongod',
        group       => 'mongod',
        mode        => '0600',
    }

    java_ks { "mongossl:keystore":
        ensure       => latest,
        certificate  => '/etc/ssl/mongodb.pem',
        password     => 'changeit',
        trustcacerts => true,
        require      => File['etc/ssl/mongodb.pem'],
    }
}
