# == Define: lightblue::eap::mongo_keystore_file
#
# Adds certificates passed as a parameter to keystore on the file system
#
# === Parameters
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
define lightblue::eap::mongo_keystore_file ($file, $source) {

    # pull certificate from the source
    file { $file:
        owner  => 'root',
        group  => 'root',
        mode   => '0600',
        links  => 'follow',
        source => $source,
    }

    #This will create the keystore at the target location
    java_ks { "${name}:${lightblue::java::java_home}/jre/lib/security/cacerts" :
        ensure       => latest,
        certificate  => $file,
        private_key  => $file,
        password     => $lightblue::eap::mongossl::java_ks_password,
        trustcacerts => true,
        require      => [ File[$file]],
    }

}
