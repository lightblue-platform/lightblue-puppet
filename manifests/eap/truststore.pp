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
# [*certificates*]
#   Hash of multiple certificates containing the alias, source and file path for each one.
#   name: Name for cert that will be used as alias in keystore, i.e. 'cacert':
#   source: Is used as 'source' in a 'file' entry, i.e. "puppet:///modules/certificates/cacert"
#   file: Full path and filename for the server certificate., i.e. "/cacert"
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::eap::truststore (
    $keystore_alias,
    $keystore_location,
    $keystore_password,
    $certificates = undef,
)
{
    file {"${lightblue::eap::truststore::keystore_location}/eap6trust.keystore":
        owner   => 'jboss',
        group   => 'jboss',
        mode    => '0600',
        notify  => Service['jbossas']
    }

    #### START Puppet iteration black magic
    # TODO change this to use new Puppet iteration Syntax
    # when we upgrade to Puppet 4 i.e. $certificates.each

    # Parse certificate hash into an array of hashes
    $certificate_data = keys($certificates)

    # For each certificate in certificate_data:
    # Add it to the keystore used for truststore
    lightblue::eap::truststore_file {$certificate_data:
        certificates => $certificates
    }

    #### END Puppet iteration black magic
}
