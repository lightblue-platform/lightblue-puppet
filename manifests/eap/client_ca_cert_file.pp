# == Define: lightblue::eap::client_ca_cert_file
#
# Deploys lightblue CA certificate file
#
# === Parameters
#
# $module_path  - The path that will be used to create the CA
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
#   'module_path' => '/path/to/my/module',
#   'source'      => 'puppet:///path/to/your/cacert.pem'
#   'file'        => 'cacert.pem',
#   'mode'        => '0440',
#   'owner'       => 'jboss',
#   'group'       => 'jboss',
#   'links'       => 'follow',
# }
#
define lightblue::eap::client_ca_cert_file (
    $module_path,
    $source,
    $file,
    $mode = '0440',
    $owner = 'jboss',
    $group = 'jboss',
    $links = 'follow',
) {

    file { "${module_path}/${file}":
        mode    => $mode,
        owner   => $owner,
        group   => $group,
        links   => $links,
        source  => $source,
    }

}
