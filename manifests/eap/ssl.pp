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
# [*certificates*]
#   Hash of multiple certificates containing the alias, source and file path for each one.
#   name: Name for cert that will be used as alias in keystore, i.e. 'lightblue.io':
#   source: Is used as 'source' in a 'file' entry, i.e. "puppet:///modules/certificates/lightblue.io"
#   file: Full path and filename for the server certificate., i.e. "/lightblue.io"
#
# === Variables
#
# Module requires no global variables.
#
class lightblue::eap::ssl (
    $keystore_alias,
    $keystore_location,
    $keystore_password,
    $certificates = undef,
)
{
    include lightblue::eap::truststore

    file {"${keystore_location}/eap6.keystore":
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
    # Add it to the keystore used for SSL
    lightblue::eap::ssl_keystore_file {$certificate_data:
        certificates => $certificates
    }

    #### END Puppet iteration black magic

    # setup thread_pool (params loaded from hiera)
    include lightblue::eap::thread_pool

    # setup webconnector (params loaded from hiera)
    include lightblue::eap::webconnector
}
