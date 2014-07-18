# Setup certificate base authentication.
class lightblue::authentication::certificate {
    # jcliff is setup in base, explicit include keeps things sane
    include lightblue::base

    # get variables out of hiera
    $option_ldapAdServer = hiera('lightblue::authentication::certificate::ldapAdServer')
    $option_ldapSearchBase = hiera('lightblue::authentication::certificate::ldapSearchBase')
    $option_ldapUsername = hiera('lightblue::authentication::certificate::ldapUsername')
    $option_ldapPassword = hiera('lightblue::authentication::certificate::ldapPassword')
    $option_keystorePassword = hiera('lightblue::authentication::certificate::keystorePassword')
    $option_keystoreUrl = hiera('lightblue::authentication::certificate::keystoreUrl')
    $option_truststorePassword = hiera('lightblue::authentication::certificate::truststorePassword')
    $option_truststoreUrl = hiera('lightblue::authentication::certificate::truststoreUrl')

    lightblue::jcliffconfig { 'lightblue-security-domain.conf':
        content => template('lightblue/lightblue-security-domain.conf.erb'),
    }
}
