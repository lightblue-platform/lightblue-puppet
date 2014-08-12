# == Class: lightblue::service::data
#
# Deploys lightblue data (crud) RESTful service.
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
# include lightblue::service::data
#
class lightblue::service::data inherits lightblue::service {
    include lightblue::base
    include lightblue::yumrepo::lightblue

    $package_name = hiera('lightblue::service::data::package::name', 'lightblue-rest-crud')
    $package_ensure = hiera('lightblue::service::data::package::ensure', latest)

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-rest-crud-cert-auth' {
      include lightblue::authentication::certificate
    }
}
