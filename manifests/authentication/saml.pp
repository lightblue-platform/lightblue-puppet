# == Class: lightblue::authentication::saml
#
# Setup security domain for saml.
#
# === Parameters
# Module requires no global variables.
#
# === Variables
#
# Module requires no global variables.
#
# Setup saml base authentication.
class lightblue::authentication::saml (
    $identity_url,
    $key_store_source,
    $key_store_url,
    $key_store_pass,
    $signing_key_pass,
    $signing_key_alias,
    $validating_key_alias,
    $validating_alias_value,
    $service_url='',
) {
    include lightblue::eap

    # Land key store on file system
    file { $key_store_url :
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        links   => 'follow',
        source  => $key_store_source,
        notify  => Service['jbossas'],
    }

    lightblue::jcliff::config { 'lightblue-security-domain-saml.conf':
        content => template('lightblue/lightblue-security-domain-saml.conf.erb')
    }

    lightblue::jcliff::config { 'lightblue-system-properties-saml.conf':
        content => template('lightblue/lightblue-system-properties-saml.conf.erb')
    }
}
