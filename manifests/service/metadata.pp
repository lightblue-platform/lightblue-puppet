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
# include lightblue::service::metadata
#
class lightblue::service::metadata inherits lightblue::service {
    include lightblue::base
    include lightblue::yumrepo::lightblue

    $package_name = hiera('lightblue::service::metadata::package::name', 'lightblue-rest-metadata')
    $package_ensure = hiera('lightblue::service::metadata::package::ensure', latest)

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }
    
    if $package_name == 'lightblue-rest-metadata-cert-auth' {
      include lightblue::authentication::certificate
    }
}
