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
# Setup certificate base authentication.
class lightblue::authentication::saml {
    include lightblue::eap

    lightblue::jcliff::config { 'lightblue-security-domain-saml.conf':
        content => template('lightblue/lightblue-security-domain-saml.conf.erb'),
        require => File["${config_dir}/roles.properties"],
    }
}
