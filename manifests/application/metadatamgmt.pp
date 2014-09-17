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
}
