# == Define: lightblue::eap::client_ca_cert_file
#
# Deploys lightblue CA certificate file
#
# === Parameters
#
# $file_path    - The path that will be used to create the CA
# $source       - The source of the CA certificate file that will be created
# $file         - The name of the CA certificate file that will be created
# $mode         - The user to whom the file should belong. Defaults to '0440',
# $owner        - The user to whom the file should belong. Defaults to 'jboss',
# $group        - The group to whom the file should belong. Defaults to 'jboss',
# $links        - Specifie how file links should be handled. Defaults to 'follow'
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# lightblue::eap::client_ca_cert_file { :
#   'file_path'   => '/path/to/my/module',
#   'source'      => 'puppet:///path/to/your/cacert.pem'
#   'file'        => 'cacert.pem',
#   'mode'        => '0440',
#   'owner'       => 'jboss',
#   'group'       => 'jboss',
#   'links'       => 'follow',
# }
#
define lightblue::client::cert_file (
    $file_path,
    $source,
    $file,
    $owner,
    $group,
    $mode = '0440',
    $links = 'follow',
    $notify = undef,
) {

    file { "${file_path}/${file}":
        mode    => $mode,
        owner   => $owner,
        group   => $group,
        links   => $links,
        source  => $source,
        require => File[$file_path],
        notify  => $notify,
    }

}
