#
class lightblue::eap::module::datasources (
    $directory,
    $mongo_auth_mechanism,
    $mongo_auth_username,
    $mongo_auth_password,
    $mongo_auth_source,
    $mongo_data_max_query_time_ms = 75000,
    $mongo_metadata_read_preference = 'primaryPreferred',
    $mongo_data_read_preference = 'primaryPreferred',
    $mongo_metadata_write_concern = undef,
    $mongo_data_write_concern = undef,
    $mongo_servers_cfg = undef,
    $mongo_ssl = true,
    $mongo_max_result_set_size = 15000,
    $mongo_connections_per_host = undef,
    $mongo_no_cert_validation = false,
    $ldap_config = undef,
    $rdbms_servers_cfg = undef,
)
{

    if !$mongo_no_cert_validation {
        # deploy truststore and mongossl
        include lightblue::eap::truststore
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
