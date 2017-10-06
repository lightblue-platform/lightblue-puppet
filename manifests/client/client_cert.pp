# == Define: lightblue::application::healthcheck_client
#
# Deploys lightblue healthcheck client certs
#
# === Parameters
#
# $module_path              Path to modules directory where client config files will be created
# $data_service_uri         URI to lightblue data service
# $metadata_service_uri     URI to lightblue metadata service
# $use_cert_auth            Boolean to determine whether cert auth is being used or not
# $source                   Source for client certificate
# $file                     File name that will be generated on the host
# $password                 Password for client certificate
# $ca_certificates          CA certificate(s) to be used in client config
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
define lightblue::client::client_cert (
    $file_path,
    $data_service_uri ,
    $metadata_service_uri,
    $use_cert_auth,
    $source,
    $file,
    $password,
    $ca_certificates,
    $owner,
    $group,
    $certAlias = undef,
    $mode = '0440',
    $links = 'follow',
    $notify = undef,
    $use_physical_file = false,
    $mongo_write_concern = undef,
    $mongo_read_preference = undef,
) {

    lightblue::client::cert_file{ "cert-${name}":
      file_path => $file_path,
      file      => $file,
      mode      => $mode,
      owner     => $owner,
      group     => $group,
      links     => $links,
      source    => $source,
      notify    => $notify,
    }

    lightblue::client::configure{ "${file_path}/${name}.properties":
        owner                          => $owner,
        group                          => $group,
        lbclient_metadata_uri          => $metadata_service_uri,
        lbclient_data_uri              => $data_service_uri,
        lbclient_use_cert_auth         => $use_cert_auth,
        lbclient_cert_file_path        => $file,
        lbclient_cert_password         => $password,
        lbclient_cert_alias            => $certAlias,
        lbclient_ca_certificates       => $ca_certificates,
        lbclient_use_physical_file     => $use_physical_file,
        base_file_path                 => $file_path,
        notify                         => $notify,
        lbclient_mongo_write_concern   => $mongo_write_concern,
        lbclient_mongo_read_preference => $mongo_read_preference,
    }

}
