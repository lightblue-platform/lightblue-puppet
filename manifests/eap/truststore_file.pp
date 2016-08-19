# == Define: lightblue::eap::ssl_truststore_file
#
# Adds certificates passed as a parameter to truststore on the file system
#
# === Parameters
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
define lightblue::eap::truststore_file ($source, $file) {

    # pull certificate from the source
    file { $file :
        owner  => 'root',
        group  => 'root',
        mode   => '0600',
        links  => 'follow',
        source => $source,
    }

    #This will create the truststore at the target location
    java_ks { "${name}:${lightblue::eap::truststore::keystore_location}/eap6trust.keystore" :
        ensure       => latest,
        certificate  => $file,
        password     => $lightblue::eap::truststore::keystore_password,
        trustcacerts => true,
        require      => [ File[$file]],
    }

}
