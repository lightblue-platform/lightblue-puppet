# == Class: lightblue::cacert
#
# Deploys cacert.  Possibly used for SSL termination (lightblue::eap::ssl) and MongoDB SSL connection (lightblue::eap::module).
#
# === Parameters
#
# [*ca_source*]
#   Location for CA identiy.  Is used as 'source' in a 'file' entry.
#
# [*ca_location*]
#   Location (local directory) for CA files.
#
# [*ca_file*]
#   File name for the ca cert.  Assumes does not include location.
#
# === Variables
#
# [*create_lightblue_cacert*]
#   If true, deploy the cacert.
#   If false, do nothing.
#   If undef, treat as true and deploy the cacert.
#
class lightblue::cacert (
    $ca_source,
    $ca_location,
    $ca_file,
) {
    if $::create_lightblue_cacert==undef or $::create_lightblue_cacert {
        file { $ca_location:
            ensure => directory,
            owner  => 'root',
            group  => 'root',
        }
        file { "${ca_location}/${ca_file}":
            owner   => 'root',
            group   => 'root',
            mode    => '0600',
            links   => 'follow',
            source  => $ca_source,
            require => File[$ca_location],
        }
    }
}
