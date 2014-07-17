# Sets up a base node with ligthblue data service deployed
class lightblue::service::data {
    include lightblue::base

    $package_name = hiera('lightblue::package::rest_crud::name', 'lightblue-rest-crud')
    $package_ensure = hiera('lightblue::package::rest_crud::ensure', latest)

    package { $package_name :
        ensure  => $package_ensure,
        require => [ Class['lightblue::yumrepos'], Class['lightblue::eap'] ],
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
