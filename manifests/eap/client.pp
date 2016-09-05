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
#   JBoss module. This will only be used if $ssl_ca_certificates is not defined.
#
# [*ssl_ca_file_path*]
#   The destination file path inside the JBoss module to put the SSL
#   certificate authority file. Defaults to 'cacert.pem'. This will only
#   be used if $ssl_ca_certificates is not defined.
#
# [*ssl_ca_certificates*]
#   List of The destination file path inside the JBoss module to put the SSL
#   certificate authority file. Defaults to the values provided in the
#   $ssl_ca_file_path and $ssl_ca_source variables for backwards compatibility.
#   If this is defined, the values for $ssl_ca_file_path and $ssl_ca_source will
#   be ignored
#
# === Variables
#
# None
#
# === Examples
#
#   Simple config (only 1 CA cert, one client cert)
#
#    lightblue::eap::client { 'myapp' :
#        data_service_uri     => 'https://mylightblue.mycompany.com/rest/data',
#        metadata_service_uri => 'https://mylightblue.mycompany.com/rest/metadata',
#        use_cert_auth        => true,
#        auth_cert_source     => 'puppet:///path/to/your/lb-myapp.pkcs12',
#        auth_cert_password   => hiera('myapp::lightblue::pass'),
#        ssl_ca_source        => 'puppet:///path/to/your/cacert.pem',
#        ssl_ca_file_path     => 'cacert.pem'
#    }
#
#
#   Multiple CA cert config
#
#     lightblue::eap::client { 'myapp' :
#        data_service_uri     => 'https://mylightblue.mycompany.com/rest/data',
#        metadata_service_uri => 'https://mylightblue.mycompany.com/rest/metadata',
#        use_cert_auth        => true,
#        auth_cert_source     => 'puppet:///path/to/your/lb-myapp.pkcs12',
#        auth_cert_password   => hiera('myapp::lightblue::pass'),
#        ssl_ca_certificates      => {'cacert.pem' => {'source' => 'puppet:///path/to/your/cacert.pem', 'file' => 'cacert.pem'}}
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
    $ssl_ca_file_path='cacert.pem',
    $ssl_ca_certificates = undef,
)
{
    require lightblue::eap::client::modulepath

    $module_path = "/usr/share/jbossas/modules/com/redhat/lightblue/client/${name}/main"

    $module_dirs = ["/usr/share/jbossas/modules/com/redhat/lightblue/client/${name}", $module_path]

    # Setup the properties directory
    # mkdir -p equivalent in puppet is crazy :/
    # Setup the module directory
    file { $module_dirs :
        ensure => 'directory',
        owner  => 'jboss',
        group  => 'jboss',
        mode   => '0440',
    }

    file { "${module_path}/module.xml":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/moduleclient.xml.erb'),
        require => File[$module_dirs],
    }

    if ',' in $ssl_ca_file_path or ',' in $ssl_ca_source {
        fail('If using multiple CA certificates, specify them as a hash in the $ssl_ca_certificates parameter')
    }

    if $ssl_ca_certificates == undef {
        $ssl_ca_cert_files = {
            "${ssl_ca_file_path}" => {
                source  => $ssl_ca_source,
                file    => $ssl_ca_file_path },
        }
    } else {
        $ssl_ca_cert_files = $ssl_ca_certificates
    }

    $ssl_ca_cert_file_defaults = {
        'module_path'   => $module_path,
        'mode'          => '0440',
        'owner'         => 'jboss',
        'group'         => 'jboss',
        'links'         => 'follow',
    }

    create_resources(lightblue::eap::client_ca_cert_file, $ssl_ca_cert_files, $ssl_ca_cert_file_defaults)

    if $use_cert_auth {
        if $auth_cert_content {
            file { "${module_path}/${auth_cert_file_path}":
                mode    => '0440',
                owner   => 'jboss',
                group   => 'jboss',
                links   => 'follow',
                content => $auth_cert_content,
                require => File[$module_dirs],
            }
        } elsif $auth_cert_source {
            file { "${module_path}/${auth_cert_file_path}":
                mode    => '0440',
                owner   => 'jboss',
                group   => 'jboss',
                links   => 'follow',
                source  => $auth_cert_source,
                require => File[$module_dirs],
            }
        } else {
            fail('If using certificate authentication, a source certificate or certificate content must be provided.')
        }
    }

    lightblue::client::configure{ "${module_path}/lightblue-client.properties":
        owner                       => 'jboss',
        group                       => 'jboss',
        lbclient_metadata_uri       => $metadata_service_uri,
        lbclient_data_uri           => $data_service_uri,
        lbclient_use_cert_auth      => $use_cert_auth,
        lbclient_ca_file_path       => $ssl_ca_file_path,
        lbclient_cert_file_path     => $auth_cert_file_path,
        lbclient_cert_password      => $auth_cert_password,
        lbclient_cert_alias         => $auth_cert_alias,
        lbclient_ca_certificates    => $ssl_ca_cert_files,
        require                     => File[$module_dirs],
    }
}
