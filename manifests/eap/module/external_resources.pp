# creates the external resources configuration file
class lightblue::eap::module::external_resources (
  $directory,
  $external_resources = undef
)
{
    file { "${directory}/lightblue-external-resources.json":
        ensure  => 'file',
        mode    => '0644',
        owner   => 'jboss',
        group   => 'jboss',
        content => template('lightblue/properties/lightblue-external-resources.json.erb'),
        require => File[$directory],
    }
}
