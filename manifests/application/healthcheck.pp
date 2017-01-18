# == Class: lightblue::application::healthcheck
#
# Deploys lightblue healthcheck application.
#
# There is some client configuration duplicated from lightblue::eap::client,
# as that doesn't really work with multiple client certificates (although I
# tried in vain for many hours to use that existing class)
#
# === Parameters
#
class lightblue::application::healthcheck (
    $data_service_uri,
    $metadata_service_uri,
    $use_cert_auth,
    $ca_certificates = undef,
    $client_certificates = undef,
    $package_name = 'lightblue-healthcheck',
    $package_ensure = latest,
) {

    package { $package_name :
        ensure  => $package_ensure,
        require => [
            Class['lightblue::yumrepo::lightblue'],
            Class['lightblue::eap'] ],
    }

    # The standard puppet way to create dirs recursively does not work when paths overlap
    # They do, because many modules are created in /usr/share/jbossas/modules/com...
    exec { $module_path:
        command => "mkdir -p ${module_path}",
        user    => 'jboss',
    }

    $module_path = '/usr/share/jbossas/modules/com/redhat/lightblue/client/healthcheck/main'
    $module_dirs = ['/usr/share/jbossas/modules/com/redhat/lightblue/client/healthcheck', $module_path]

    # Setup the module directory
    file { $module_dirs :
        ensure => 'directory',
        owner  => 'jboss',
        group  => 'jboss',
        mode   => '0440',
    }

    file { "${module_path}/module.xml":
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/modulehealthcheckclient.xml.erb'),
        require => File[$module_dirs],
    }

    $ca_certificates_default = {
        'module_path'   => $module_path,
        'mode'          => '0440',
        'owner'         => 'jboss',
        'group'         => 'jboss',
        'links'         => 'follow',
    }

    create_resources(lightblue::eap::client_ca_cert_file, $ca_certificates, $ca_certificates_default)

    $client_defaults = {
        'module_path'          => $module_path,
        'data_service_uri'     => $data_service_uri,
        'metadata_service_uri' => $metadata_service_uri,
        'use_cert_auth'        => $use_cert_auth,
        'ca_certificates'      => $ca_certificates,
    }

    create_resources(lightblue::application::healthcheck_client, $client_certificates, $client_defaults)

    $clients_config_file_name = 'lightblue-clients.config'
    $clients_config_file_path = "${module_path}/${clients_config_file_name}"

    concat { $clients_config_file_path :
        ensure => present,
        mode   => '0440',
        owner  => 'jboss',
        group  => 'jboss',
    }

    $client_cert_keys = keys($client_certificates)

    # This is just there to make sure the last key in the array gets .properties\n appended, kinda hacky but works
    $client_cert_keys[size($client_cert_keys)]=''

    concat::fragment { $clients_config_file_path:
        target  => $clients_config_file_path,
        content => join($client_cert_keys, ".properties\n"),
    }

}
