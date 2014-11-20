# == Define: lightblue::eap::client
#
# Client configuration for lightblue: ssl ca cert and cert for authentication.
# Most settings have resonable defaults in hiera.
#
# === Parameters
#
# [*service_uri_data*]
#   Description required.
#
# [*service_uri_metadata*]
#   Description required.
#
# [*auth_cert_source*]
#   Description required.
#
# [*ssl_ca_file_path*]
#   Description required.
#
# [*auth_cert_file_path*]
#   Description required.
#
# [*auth_cert_password*]
#   Description required.
#
# [*auth_cert_alias*]
#   Description required.
#
# === Variables
#
# None
#
# === Examples
#
#    lightblue::eap::client { 'tncadmin' :
#        auth_cert_source => hiera('appsjboss7::lightblue::app::tncadmin::cert'),
#        auth_cert_password => hiera('appsjboss7::lightblue::app::tncadmin::pass'),
#    }
#
define lightblue::eap::client (
    $service_uri_data=hiera('lightblue::endpoint::data'),
    $service_uri_metadata=hiera('lightblue::endpoint::metadata'),
    $auth_cert_source="puppet:///certificates/pkcs12/lb-${name}.pkcs12",
    $ssl_ca_file_path="cacert.pem",
    $auth_cert_file_path="lb-${name}.pkcs12",
    $auth_cert_password,
    $auth_cert_alias="lb-${name}")
{
    include lightblue::eap::client::modulepath

    $module_path = "/usr/share/jbossas/modules/com/redhat/lightblue/client/${name}/main"

    $module_dirs = ["/usr/share/jbossas/modules/com/redhat/lightblue/client/${name}", $module_path]

    # Setup the properties directory
    # mkdir -p equivalent in puppet is crazy :/
    file { $module_dirs :
        ensure   => 'directory',
        owner    => 'jboss',
        group    => 'jboss',
        mode     => '0755',
        require  => Class['lightblue::eap::client::modulepath']
    }

    file { "${module_path}/module.xml":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/moduleclient.xml.erb'),
        notify  => Service['jbossas'],
        require => File[$module_dirs],
    }

    file { "${module_path}/appconfig.properties":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/appconfigclient.properties.erb'),
        notify  => Service['jbossas'],
        require => File[$module_dirs],
    }

    file { "${module_path}/${ssl_ca_file_path}":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        links   => 'follow',
        source  => hiera('lightblue::client_ca_source'),
        notify  => Service['jbossas'],
        require => File[$module_dirs],
    }

    file { "${module_path}/${auth_cert_file_path}":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        links   => 'follow',
        source  => $auth_cert_source,
        notify  => Service['jbossas'],
        require => File[$module_dirs],
    }

}
