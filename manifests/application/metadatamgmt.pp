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
    $mgmt_app_data_service_uri,
    $mgmt_app_metadata_service_uri,
    $mgmt_app_use_cert_auth,
    $mgmt_app_cert_file_path,
    $mgmt_app_cert_password,
    $mgmt_app_cert_alias,
    $client_ca_source,
    $client_cert_source,
    $ca_certificates = undef,
)
inherits lightblue::application {
    include lightblue::base
    include lightblue::yumrepo::lightblue

    package { $package_name :
        ensure  => $package_ensure,
        require => [
          Class['lightblue::yumrepo::lightblue'],
          Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-metadata-mgmt-saml-auth' {
      include lightblue::authentication::saml
    }

    lightblue::eap::client { 'metadata-mgmt':
        data_service_uri     => $mgmt_app_data_service_uri,
        metadata_service_uri => $mgmt_app_metadata_service_uri,
        use_cert_auth        => $mgmt_app_use_cert_auth,
        auth_cert_source     => $client_cert_source,
        auth_cert_password   => $mgmt_app_cert_password,
        auth_cert_file_path  => $mgmt_app_cert_file_path,
        auth_cert_alias      => $mgmt_app_cert_alias,
        ssl_ca_source        => $client_ca_source,
        ssl_ca_certificates      => $ca_certificates
    }

}
