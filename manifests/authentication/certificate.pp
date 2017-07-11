# == Class: lightblue::authentication::certificate
#
# Setup security domain for client certificates.
#
# === Parameters
# [*config_dir*]
#   EAP configuration directory
#   i.e. /usr/share/jbossas/standalone/configuration
#
# [*ldap_server*]
#   ldap server
#   i.e. ldap.mycompany.com (do not add ldap://)
#
# [*ldap_port*]
#   ldap port
#   i.e. 389
#
# [*ldap_search_base*]
#   base query for getting at lightblue group data
#   i.e. uid=lightblueapp,ou=serviceusers,ou=lightblue,dc=mycompany,dc=com
#
# [*ldap_username*]
#   user for accessing lightblue group data
#
# [*ldap_password*]
#   password for the user
#
# [*ldap_use_tls*]
#   boolean to represent whether or not TLS should be used to connect to LDAP
#
# [*ldap_pool_size*]
#   integer to represent the LDAP connection pool size
#
# [*keystore_password*]
#   keystore password
#
# [*keystore_url*]
#   keystore url
#
# [*truststore_password*]
#   Password to truststore.  Should be same as keystore password.
#   TBD reference to why keystore and truststore passwords must be same.
#
# [*truststore_url*]
#   URL to truststore.
#
# [*connectionTimeoutMS*]
#   LDAP Connection establish timeout.
#
# [*responseTimeoutMS*]
#   LDAP response timeout.
#
# [*debug*]
#   Debug logs from unboundID.
#
# [*keepAlive*]
#   LDAP connection keep alive.
#
# [*poolMaxConnectionAgeMS*]
#   Max LDAP connection age in the pool.
#
# === Variables
#
# Module requires no global variables.
#
# Setup certificate base authentication.
class lightblue::authentication::certificate (
    $config_dir,
    $ldap_server,
    $ldap_port,
    $ldap_search_base,
    $ldap_username,
    $ldap_password,
    $ldap_use_tls=false,
    $ldap_pool_size,
    $environment,
    $keystore_password,
    $keystore_url,
    $truststore_password,
    $truststore_url,
    $connectionTimeoutMS=3000,
    $responseTimeoutMS=3000,
    $debug=false,
    $keepAlive=true,
    $poolMaxConnectionAgeMS=15000,
) {
    include lightblue::eap

    # create empty roles.properties file required for login module to work
    file {"${config_dir}/roles.properties":
        ensure  => present,
        content => '',
        owner   => 'jboss',
        group   => 'jboss',
        mode    => '0644',
        require => Package[$lightblue::eap::package_name],
    }

    # create ldap-healthcheck-config.json file required to initialize RolesProvider
    file { "${directory}/ldap-healthcheck-config.json":
        ensure  => 'file',
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/ldap-healthcheck-config.json.erb'),
        require => File[$directory],
    }

    lightblue::jcliff::config { 'lightblue-security-domain-cert.conf':
        content => template('lightblue/lightblue-security-domain-cert.conf.erb'),
        require => File["${config_dir}/roles.properties"],
    }
}
