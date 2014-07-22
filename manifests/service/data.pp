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
class lightblue::service::data {
    include lightblue::base
    include lightblue::yumrepo::lightblue

    $package_name = hiera('lightblue::service::data::package::name', 'lightblue-rest-crud')
    $package_ensure = hiera('lightblue::service::data::package::ensure', latest)

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-crud.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-crud.json.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }
}
