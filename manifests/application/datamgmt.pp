# == Class: lightblue::application::datamgmt
#
# Deploys lightblue data management application.
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
# include lightblue::application::datamgmt
#
class lightblue::application::datamgmt (
    $package_name = 'lightblue-data-mgmt',
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
    include lightblue::logging
    include lightblue::yumrepo::lightblue

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-data-mgmt-saml-auth' {
        include lightblue::authentication::saml

        lightblue::jcliff::config { 'data-mgmt-system-properties.conf': 
            content => "{ 'system-property' => { 'DataMgmtURL' => '${app_uri}' } }"
        }
    }

    lightblue::eap::client { 'data-mgmt' 
        data_service_uri     => ${data_service_uri},
        metadata_service_uri => ${metadata_service_uri},
        use_cert_auth        => ${use_cert_auth},
        auth_cert_source     => ${auth_cert_source},
        auth_cert_password   => ${auth_cert_password},
        ssl_ca_source        => ${ssl_ca_source},
    }
}
