# == Class: lightblue::application::migrator
#
# Deploys lightblue healthcheck application.
#
# === Parameters
#
class lightblue::application::healthcheck (
    $package_name = 'lightblue-healthcheck',
    $package_ensure = latest,
    $data_service_uri,
    $metadata_service_uri,
    $use_cert_auth,
    $cert_file_path,
    $cert_password,
    $cert_alias,
    $client_ca_source,
    $client_cert_source,
) {
  
    package { $package_name :
        ensure  => $package_ensure,
        require => [
            Class['lightblue::yumrepo::lightblue'],
            Class['lightblue::eap'] ],
    }
    
    lightblue::eap::client { 'test':
        data_service_uri     => $data_service_uri,
        metadata_service_uri => $metadata_service_uri,
        use_cert_auth        => $use_cert_auth,
        auth_cert_source     => $client_cert_source,
        auth_cert_password   => $cert_password,
        auth_cert_file_path  => $cert_file_path,
        auth_cert_alias      => $cert_alias,
        ssl_ca_source        => $client_ca_source
    }
  
}
