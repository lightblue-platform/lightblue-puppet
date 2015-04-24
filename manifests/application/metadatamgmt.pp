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
)
inherits lightblue::application {
    include lightblue::base
    include lightblue::yumrepo::lightblue

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-metadata-mgmt-saml-auth' {
      include lightblue::authentication::saml
    }

    # It would be prettier to rename all mgmt_app keys in hiera for lightblue::application::metadatamgmt class
    lightblue::eap::client { "metadata-mgmt":
        data_service_uri => hiera('lightblue::endpoint::service::data'),
        metadata_service_uri => hiera('lightblue::endpoint::service::metadata'),
        use_cert_auth => hiera('lightblue::eap::module::mgmt_app_use_cert_auth'),
        auth_cert_source => hiera('lightblue::eap::module::client_cert_source'),
        auth_cert_password => hiera('lightblue::eap::module::mgmt_app_cert_password'),
        auth_cert_file_path => hiera('lightblue::eap::module::mgmt_app_cert_file_path'),
        auth_cert_alias => hiera('lightblue::eap::module::mgmt_app_cert_alias'),
        ssl_ca_source => hiera('lightblue::client_ca_source'),
    }

}
