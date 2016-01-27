# creates the external resources configuration file
class lightblue::eap::module::external_resources (
  $directory,
  $external_resources = undef,
  $file_name = "lightblue-external-resources.json",
)
{
    $path = "${directory}/${file_name}"
  
    if($external_resources != undef){
      file {$path :
          ensure  => 'file',
          mode    => '0644',
          owner   => 'jboss',
          group   => 'jboss',
          content => template('lightblue/properties/lightblue-external-resources.json.erb'),
          require => File[$directory],
      }
    }
    else{
      file { $path:
          ensure  => 'absent',
      }
    }
    
}
