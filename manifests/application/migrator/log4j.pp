class lightblue::application::migrator::log4j(
  $log_level = 'INFO',
  $log_file_name = 'migrator.log',
  $log_max_file_size = '1MB',
  $log_max_backups_to_keep = '5',
  $log_pattern = '%d [%t] %c %p - %m%n',
  $config_dir,
  $log_dir,
  $owner,
  $group,
  $service_name
) {

  $log4j_config_file = "$config_dir/log4j.properties"
  $log_file = "$log_dir/$log_file_name"

  file{ $log4j_config_file:
    ensure  => 'file',
    mode    => '0644',
    owner   => $owner,
    group   => $group,
    content => template('lightblue/application/migrator/log4j.properties.erb'),
    notify  => [Service[$service_name]]
  }

}