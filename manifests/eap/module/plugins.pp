# creates the plugins configuration file
class lightblue::eap::module::plugins (
  $directory,
  $plugins = undef,
  $file_name = 'lightblue-plugins.json',
)
{
    $path = "${directory}/${file_name}"

    if($plugins != undef){
      file {$path :
          ensure  => 'file',
          mode    => '0644',
          owner   => 'jboss',
          group   => 'jboss',
          content => template('lightblue/properties/lightblue-plugins.json.erb'),
          require => File[$directory],
      }
    }
    else{
      file { $path:
          ensure  => 'absent',
      }
    }

}
