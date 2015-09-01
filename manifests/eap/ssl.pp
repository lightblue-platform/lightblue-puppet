# == Class: lightblue::eap::ssl
#
# Deploys ssl certificate and setups java keystore for use by jboss.  Also configures
# webconnector and thread_pool to support terminating ssl traffic.
#
# === Parameters
#
# [*keystore_alias*]
#   alias to the keystore
#
# [*keystore_location*]
#   Directory where keystore is saved.
#
# [*keystore_password*]
#   Password to keystore.
#
# [*server_certificate_source*]
#   Location for server certificate.  Is used as 'source' in a 'file' entry.
#   Recommend referencing a file in a separate (and secure) puppet module for managing certs.
#
# [*server_certificate_file*]
#   Full path and filename for the server certificate.
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::eap::ssl (
    $keystore_alias,
    $keystore_location,
    $keystore_password,
    $server_certificate_source,
    $server_certificate_file,
)
{
    include lightblue::eap::truststore

    # pull certificate from the source
    file { $server_certificate_file:
        owner  => 'root',
        group  => 'root',
        mode   => '0600',
        links  => 'follow',
        source => $server_certificate_source,
    }
    #This will create the keystore at the target location, with the alias eap6 to the cert
    java_ks { "${keystore_alias}:keystore":
        ensure       => latest,
        certificate  => $server_certificate_file,
        private_key  => $server_certificate_file,
        target       => "${keystore_location}/eap6.keystore",
        password     => $keystore_password,
        trustcacerts => true,
        require      => [ File[$server_certificate_file], Package[$lightblue::eap::package_name] ],
    }
    file {"${keystore_location}/eap6.keystore":
        owner   => 'jboss',
        group   => 'jboss',
        mode    => '0600',
        require => Java_ks["${keystore_alias}:keystore"],
    }

    # setup thread_pool (params loaded from hiera)
    include lightblue::eap::thread_pool

    # setup webconnector (params loaded from hiera)
    include lightblue::eap::webconnector
}
