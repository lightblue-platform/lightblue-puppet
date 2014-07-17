# Setup certificate base authentication.
class lightblue::authentication::certificate {
    # jcliff is setup in base, explicit include keeps things sane
    include lightblue::base

    # get variables out of hiera
    $option_ldapAdServer = hiera('lightblue::auth::cert::ldapAdServer')
    $option_ldapSearchBase = hiera('lightblue::auth::cert::ldapSearchBase')
    $option_ldapUsername = hiera('lightblue::auth::cert::ldapUsername')
    $option_ldapPassword = hiera('lightblue::auth::cert::ldapPassword')
    $option_keystorePassword = hiera('lightblue::auth::cert::keystorePassword')
    $option_keystoreUrl = hiera('lightblue::auth::cert::keystoreUrl')
    $option_truststorePassword = hiera('lightblue::auth::cert::truststorePassword')
    $option_truststoreUrl = hiera('lightblue::auth::cert::truststoreUrl')

    lightblue::jcliffconfig { 'lightblue-security-domain.conf':
        content => template('lightblue/lightblue-security-domain.conf.erb'),
    }
}
