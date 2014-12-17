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
class lightblue::service::metadata (
    $package_name = 'lightblue-rest-metadata',
    $package_ensure = latest,
)
inherits lightblue::service {
    require lightblue::service::plugin::graphite

    include lightblue::base
    include lightblue::yumrepo::lightblue

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-rest-metadata-cert-auth' {
      include lightblue::authentication::certificate
    }
}
