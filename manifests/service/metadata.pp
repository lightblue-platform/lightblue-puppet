# Sets up a base node with ligthblue metadata service deployed
class lightblue::service::metadata {
    include lightblue::base
    include lightblue::yumrepo::lightblue

    $package_name = hiera('lightblue::service::metadata::package::name', 'lightblue-rest-metadata')
    $package_ensure = hiera('lightblue::service::metadata::package::ensure', latest)

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepo::lightblue'], Class['lightblue::eap'] ],
    }

    file { '/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-metadata.json':
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-metadata.json.erb'),
        notify  => Service['jbossas'],
        require => File['/usr/share/jbossas/modules/com/redhat/lightblue/main'],
    }
}
