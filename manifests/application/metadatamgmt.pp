# == Class: lightblue::service::metadata
#
# Deploys lightblue metadata RESTful service.
#
# === Parameters
#
# No parameters.
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# include lightblue::application::metadatamgmt
#
class lightblue::application::metadatamgmt (
    $package_name = 'lightblue-metadata-mgmt',
    $package_ensure = latest,
    $app_uri,
    $data_service_uri,
    $metadata_service_uri,
    $use_cert_auth = false,
    $auth_cert_source = undef,
    $auth_cert_content = undef,
    $auth_cert_password = undef,
    $ssl_ca_source = undef,
)
inherits lightblue::application {
    # Include base until application is updated to use new config; then just
    # include lightblue::logging.
    include lightblue::base
    include lightblue::yumrepo::lightblue

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-metadata-mgmt-saml-auth' {
        include lightblue::authentication::saml 

        lightblue::jcliff::config { 'metadata-mgmt-system-properties.conf': 
            content => "{ 'system-property' => { 'MetadataMgmtURL' => '${app_uri}' } }",
        }
    }

    lightblue::eap::client { 'metadata-mgmt' 
        data_service_uri     => ${data_service_uri},
        metadata_service_uri => ${metadata_service_uri},
        use_cert_auth        => ${use_cert_auth},
        auth_cert_source     => ${auth_cert_source},
        auth_cert_password   => ${auth_cert_password},
        ssl_ca_source        => ${ssl_ca_source},
    }
}
