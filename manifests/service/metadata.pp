# Sets up a base node with ligthblue metadata service deployed
class lightblue::service::metadata {
    include lightblue::base

    $package_name = hiera('lightblue::package::rest_metadata::name', 'lightblue-rest-metadata')
    $package_ensure = hiera('lightblue::package::rest_metadata::ensure', latest)

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepos'], Class['lightblue::eap'] ],
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
