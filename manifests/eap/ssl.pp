# == Class: lightbluerh::eap::ssl
#
# Create keystores needed for jboss ssl.
#
# === Parameters
#
# Module requires no parameters when including.
#
# === Variables
#
# Module requires no global variables.
#
# === Examples
#
#  include lightbluerh::eap::ssl
#
class lightbluerh::eap::ssl (
    $keystore_alias,
    $keystore_location,
    $keystore_password,
    $ca_location,
    $certificate_source,
    $certificate_file,
    $enabled = true
) {
    if $enabled {
        # pull certificate from the source
        file { "${certificate_file}":
            owner   => 'root',
            group   => 'root',
            mode    => '0600',
            links   => 'follow',
            source  => $certificate_source,
        }
        #This will create the keystore at the target location, with the alias eap6 to the cert
        java_ks { "${keystore_alias}:keystore":
            ensure       => latest,
            certificate  => "${certificate_file}",
            private_key  => "${certificate_file}",
            target       => "${keystore_location}/eap6.keystore",
            password     => $keystore_password,
            trustcacerts => true,
            require      => File["${certificate_file}"],
        }
        java_ks { "${keystore_alias}:truststore":
            ensure       => latest,
            certificate  => "${ca_location}/cacert.pem",
            target       => "${keystore_location}/eap6trust.keystore",
            password     => $keystore_password,
            trustcacerts => true,
            require      => File["${certificate_file}"],
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
    }
}
