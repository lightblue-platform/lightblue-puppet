class lightblue::eap::module::metadata (
    $directory,
    $hook_configuration_parsers = '',
    $backend_parsers = undef,
    $property_parsers = undef,
    $metadata_roles=undef,
)
{
    file { "${directory}/lightblue-metadata.json":
        ensure  => 'file',
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-metadata.json.erb'),
        notify  => Service['jbossas'],
        require => File[$directory],
    }
}
