# == Define: lightblue::client::configure
#
# Deploys lightblue client configuration file.
#
# === Parameters
#
# $owner                      - The user to whom the file should belong. Defaults to 'root'.
# $group                      - The group to whom the file should belong. Defaults to 'root'.
# $lbclient_metadata_uri      - metadata uri (required)
# $lbclient_data_uri          - data uri (required)
# $lbclient_use_cert_auth     - true/false indicating if cert authentication is required. Defaults to false.
# $lbclient_ca_file_path      - ca file path. Required only if $lbclient_use_cert_auth == true.
# $lbclient_cert_file_path    - cert file path. Required only if $lbclient_use_cert_auth == true.
# $lbclient_cert_password     - cert password. Required only if $lbclient_use_cert_auth == true.
# $lbclient_cert_alias        - cert alias. Required only if $lbclient_use_cert_auth == true.
# $lbclient_use_physical_file - It is generally assumed that the cert and ca files will bundled in the application binary,
#                               however toggling to true provides the ability for the files to be physically located
#                               on the file system.
#                               (defaults to false)
# $lbclient_ca_certificates   - List of The destination file path inside the JBoss module to put the SSL
#                               certificate authority file. Defaults to the values provided in the
#                               $ssl_ca_file_path and $ssl_ca_source variables for backwards compatibility.
#
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# lightblue::client::configure{ $config_file:
#   #parameters
# }
#
define lightblue::client::configure (
    $lbclient_metadata_uri,
    $lbclient_data_uri,
    $owner = 'root',
    $group = 'root',
    $lbclient_use_cert_auth = false,
    $lbclient_ca_file_path = undef,
    $lbclient_cert_file_path = undef,
    $lbclient_cert_password = undef,
    $lbclient_cert_alias = undef,
    $lbclient_use_physical_file = false,
    $lbclient_ca_certificates = undef,
) {

    file { $title:
        ensure  => 'file',
        mode    => '0440',
        owner   => $owner,
        group   => $group,
        content => template('lightblue/client/lightblue-client.properties.erb'),
    }

}
