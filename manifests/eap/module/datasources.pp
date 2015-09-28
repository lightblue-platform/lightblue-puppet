#
class lightblue::eap::module::datasources (
    $directory,
    $mongo_auth_mechanism,
    $mongo_auth_username,
    $mongo_auth_password,
    $mongo_auth_source,
    $mongo_metadata_readPreference = 'primary',
    $mongo_data_readPreference = 'primary',
    $mongo_servers_cfg = undef,
    $mongo_ssl = true,
    $mongo_noCertValidation = false,
    $ldap_config = undef,
    $rdbms_servers_cfg = undef,
)
{

    if !$mongo_noCertValidation {
        # deploy cacert and mongossl
        include lightblue::cacert
        include lightblue::eap::mongossl
    }

    file { "${directory}/datasources.json":
        ensure  => 'file',
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/datasources.json.erb'),
        require => File[$directory],
    }
}
