# == Define: lightblue::application::healthcheck_client
#
# Deploys lightblue healthcheck client certs
#
# === Parameters
#
# $module_path              Path to modules directory where client config files will be created
# $data_service_uri         URI to lightblue data service
# $metadata_service_uri     URI to lightblue metadata service
# $use_cert_auth,
# $source,
# $file,
# $password,
# $ca_certificates,
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# lightblue::application::healthcheck_client { :
#   'data_service_uri'      => 'http://lightblue.io/rest/data',
#   'metadata_service_uri   => 'http://lightblue.io/rest/metadata',
#   'use_cert_auth          => true,
#   'source                 => 'puppet:///modules/certificates/lightblue.io',
#   'file                   => 'lightblue.io',
#   'password               => 'nothingtoseehere',
#   'ca_certificates        => {'cacert.pem' => {'source' => 'puppet:///path/to/your/cacert.pem', 'file' => 'cacert.pem'}},
# }
#
define lightblue::application::healthcheck_client (
    $module_path,
    $data_service_uri ,
    $metadata_service_uri,
    $use_cert_auth,
    $source,
    $file,
    $password,
    $ca_certificates,
) {

    $config_file_suffix = ".properties"

    lightblue::client::configure{ "${module_path}/${name}${config_file_suffix}":
        owner                       => 'jboss',
        group                       => 'jboss',
        lbclient_metadata_uri       => $metadata_service_uri,
        lbclient_data_uri           => $data_service_uri,
        lbclient_use_cert_auth      => $use_cert_auth,
        lbclient_cert_file_path     => $file,
        lbclient_cert_password      => $password,
        lbclient_cert_alias         => $name,
        lbclient_ca_certificates    => $ca_certificates,
    }

}
