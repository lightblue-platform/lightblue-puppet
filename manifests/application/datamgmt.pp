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
)
inherits lightblue::application {
    include lightblue::base
    include lightblue::yumrepo::lightblue

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-data-mgmt-saml-auth' {
      include lightblue::authentication::saml
    }
}
