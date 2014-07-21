# Setup certificate base authentication.
class lightblue::authentication::certificate (
    $ldap_ad_server,
    $ldap_search_base,
    $ldap_username,
    $ldap_password,
    $keystore_password,
    $keystore_url,
    $truststore_password,
    $truststore_url,
) {
    lightblue::jcliff::config { 'lightblue-security-domain.conf':
        content => template('lightblue/lightblue-security-domain.conf.erb'),
    }
}
