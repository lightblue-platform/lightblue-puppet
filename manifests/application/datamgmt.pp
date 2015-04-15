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
    $app_uri = undef,
)
inherits lightblue::application {
    include lightblue::eap
    include lightblue::yumrepo::lightblue

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    if $package_name == 'lightblue-data-mgmt-saml-auth' {
        include lightblue::authentication::saml

        if $app_uri == undef {
            fail('Must define $app_uri if using SAML auth with data management.')
        }

        lightblue::jcliff::config { 'data-mgmt-system-properties.conf':
            content => "{ 'system-property' => { 'DataMgmtURL' => '${app_uri}' } }"
        }
    }
}
