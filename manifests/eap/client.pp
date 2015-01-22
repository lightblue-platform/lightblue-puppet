# == Define: lightblue::eap::client
#
# Configure a lightblue JBoss client by laying down puppetized configuration
# inside a JBoss module named after the client application.
#
# === Parameters
#
# [*data_service_uri*]
#   URI of Lightblue data service.
#
# [*metadata_service_uri*]
#   URI of Lightblue metadata service.
#
# [*use_cert_auth*]
#   Flag to indicate whether or not to use certificate based authentication with
#   lightblue. Defaults to false. If true, auth_cert_source or auth_cert_content
#   must be provided.
#
# [*auth_cert_source*]
#   The source of the certificate to authenticate with the Lightblue services.
#   Will be copied to the JBoss module, unless auth_cert_content is specified.
#
# [*auth_cert_content*]
#   The content of an auth certificate to be placed inside the JBoss module.
#
# [*auth_cert_file_path*]
#   The destination file path inside the JBoss module to put the auth cert.
#   Defaults to 'lb-${name}.pkcs12'.
#
# [*auth_cert_password*]
#   The password for the auth cert.
#
# [*auth_cert_alias*]
#   The alias for the cert.
#
# [*ssl_ca_source*]
#   The source of the SSL certificate authority file. Will be copied to the
#   JBoss module.
#
# [*ssl_ca_file_path*]
#   The destination file path inside the JBoss module to put the SSL
#   certificate authority file. Defaults to 'cacert.pem'.
#
# === Variables
#
# None
#
# === Examples
#
#    lightblue::eap::client { 'myapp' :
#        data_service_uri     => 'https://mylightblue.mycompany.com/rest/data',
#        metadata_service_uri => 'https://mylightblue.mycompany.com/rest/metadata',
#        use_cert_auth        => true,
#        auth_cert_source     => 'puppet:///path/to/your/lb-myapp.pkcs12',
#        auth_cert_password   => hiera('myapp::lightblue::pass'),
#        ssl_ca_source        => 'puppet:///path/to/your/cacert.pem',
#    }
#
define lightblue::eap::client (
    $data_service_uri,
    $metadata_service_uri,
    $use_cert_auth=false,
    $auth_cert_source=undef,
    $auth_cert_content=undef,
    $auth_cert_file_path="lb-${name}.pkcs12",
    $auth_cert_password=undef,
    $auth_cert_alias="lb-${name}",
    $ssl_ca_source=undef,
    $ssl_ca_file_path="cacert.pem"
)
{
    $module_path = "/usr/share/jbossas/modules/com/redhat/lightblue/client/${name}/main"

    $module_dirs = ['/usr/share/jbossas/modules/com',
        '/usr/share/jbossas/modules/com/redhat',
        '/usr/share/jbossas/modules/com/redhat/lightblue',
        '/usr/share/jbossas/modules/com/redhat/lightblue/client',
        "/usr/share/jbossas/modules/com/redhat/lightblue/client/${name}",
        $module_path]

    # Setup the module directory
    file { $module_dirs :
        ensure   => 'directory',
        owner    => 'jboss',
        group    => 'jboss',
        mode     => '0755',
    }

    file { "${module_path}/module.xml":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/moduleclient.xml.erb'),
        notify  => Service['jbossas'],
        require => File[$module_dirs],
    }

    file { "${module_path}/${ssl_ca_file_path}":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        links   => 'follow',
        source  => $ssl_ca_source,
        notify  => Service['jbossas'],
        require => File[$module_dirs],
    }

    if $use_cert_auth {
        if defined('$auth_cert_content') {
            file { "${module_path}/${auth_cert_file_path}":
                mode    => '0644',
                owner   => 'jboss',
                group   => 'jboss',
                links   => 'follow',
                content => $auth_cert_content,
                notify  => Service['jbossas'],
                require => File[$module_dirs],
            }
        } elsif defined('$auth_cert_source') {
            file { "${module_path}/${auth_cert_file_path}":
                mode    => '0644',
                owner   => 'jboss',
                group   => 'jboss',
                links   => 'follow',
                source  => $auth_cert_source,
                notify  => Service['jbossas'],
                require => File[$module_dirs],
            }
        } else {
            fail("If using certificate authentication, a source certificate or certificate content must be provided.")
        }
    }

    lightblue::client::configure{ "${module_path}/lightblue-client.properties":
        owner                   => 'jboss',
        group                   => 'jboss',
        lbclient_metadata_uri   => $metadata_service_uri,
        lbclient_data_uri       => $data_service_uri,
        lbclient_use_cert_auth  => $use_cert_auth,
        lbclient_ca_file_path   => $ssl_ca_file_path,
        lbclient_cert_file_path => $auth_cert_file_path,
        lbclient_cert_password  => $auth_cert_password,
        lbclient_cert_alias     => $auth_cert_alias,
        notify                  => Service['jbossas'],
        require                 => File[$module_dirs],
    }
}