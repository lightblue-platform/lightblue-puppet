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
#   Directory where keystore (and truststore) are saved.
#
# [*keystore_password*]
#   Password to keystore (and truststore).
#
# [*certificate_source*]
#   Location for certificate.  Is used as 'source' in a 'file' entry.
#   Recommend referencing a file in a separate (and secure) puppet module for managing certs.
#
# [*certificate_file*]
#   Full path and filename for the certificate.
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::eap::ssl (
    $keystore_alias,
    $keystore_location,
    $keystore_password,
    $certificate_source,
    $certificate_file,
)
{
    include lightblue::cacert

    # pull certificate from the source
    file { $certificate_file:
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        links   => 'follow',
        source  => $certificate_source,
    }
    #This will create the keystore at the target location, with the alias eap6 to the cert
    java_ks { "${keystore_alias}:keystore":
        ensure       => latest,
        certificate  => $certificate_file,
        private_key  => $certificate_file,
        target       => "${keystore_location}/eap6.keystore",
        password     => $keystore_password,
        trustcacerts => true,
        require      => File[$certificate_file],
    }
    java_ks { "${keystore_alias}:truststore":
        ensure       => latest,
        certificate  => "${lightblue::cacert::ca_location}/${lightblue::cacert::ca_file}",
        target       => "${keystore_location}/eap6trust.keystore",
        password     => $keystore_password,
        trustcacerts => true,
        require      => [ File[$certificate_file], File["${lightblue::cacert::ca_location}/${lightblue::cacert::ca_file}"] ],
    }
    file {"${keystore_location}/eap6.keystore":
        owner   => 'jboss',
        group   => 'jboss',
        mode    => '0600',
        require => Java_ks["${keystore_alias}:keystore"],
    }
    file {"${keystore_location}/eap6trust.keystore":
        owner   => 'jboss',
        group   => 'jboss',
        mode    => '0600',
        require => Java_ks["${keystore_alias}:truststore"],
    }

    # setup thread_pool (params loaded from hiera)
    include lightblue::eap::thread_pool

    # setup webconnector (params loaded from hiera)
    include lightblue::eap::webconnector
}
