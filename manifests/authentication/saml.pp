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
    $service_url,
    $keystore_url,
    $keystore_pass,
    $signing_key_pass,
    $signing_key_alias,
    $validating_key_alias,
    $validating_alias_value,
) {
    include lightblue::eap

    lightblue::jcliff::config { 'lightblue-security-domain-saml.conf':
        content => template('lightblue/lightblue-security-domain-saml.conf.erb')
    }

    lightblue::jcliff::config { 'lightblue-system-properties-saml.conf':
        content => template('lightblue/lightblue-system-properties-saml.conf.erb')
    }
}
