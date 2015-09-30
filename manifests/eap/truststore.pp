# == Class: lightblue::eap::truststore
#
# Deploys keystore with identity ca for use by jboss.
#
# === Parameters
#
# [*keystore_alias*]
#   alias to the keystore
#
# [*keystore_location*]
#   Directory where keystore (truststore) is saved.
#
# [*keystore_password*]
#   Password to keystore (truststore).
#
# [*identity_certificate_source*]
#   Location for identity certificate.  Is used as 'source' in a 'file' entry.
#   Recommend referencing a file in a separate (and secure) puppet module for managing certs.
#
# [*identity_certificate_file*]
#   Full path and filename for the identity certificate.
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::eap::truststore (
    $keystore_alias,
    $keystore_location,
    $keystore_password,
    $identity_certificate_source,
    $identity_certificate_file,
)
{
    # pull certificate from the source
    file { $identity_certificate_file:
        owner  => 'root',
        group  => 'root',
        mode   => '0600',
        links  => 'follow',
        source => $identity_certificate_source,
    }
    #This will create the keystore at the target location, with the alias eap6trust to the cert
    java_ks { "${keystore_alias}:truststore":
        ensure       => latest,
        certificate  => $identity_certificate_file,
        target       => "${keystore_location}/eap6trust.keystore",
        password     => $keystore_password,
        trustcacerts => true,
        require      => [ File[$identity_certificate_file], Package[$lightblue::eap::package_name] ],
    }
    file {"${keystore_location}/eap6trust.keystore":
        owner   => 'jboss',
        group   => 'jboss',
        mode    => '0600',
        require => Java_ks["${keystore_alias}:truststore"],
    }
}
