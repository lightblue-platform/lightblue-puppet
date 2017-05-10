#
class lightblue::application::migrator::log4j(
  $config_dir,
  $log_dir,
  $owner,
  $group,
  $log_level = 'INFO',
  $log_file_name = 'migrator.log',
  $inconsistency_file_name = 'inconsistencies.log',
  $log_max_file_size = '10MB',
  $log_max_backups_to_keep = '50',
  $log_pattern = '%d [%t] %-5p [%c] %m%n',
) {

  $log4j_config_file = "${config_dir}/log4j.properties"
  $log_file = "${log_dir}/${log_file_name}"

  if $inconsistency_file_name != '' {
      $inconsistency_file = "${log_dir}/${inconsistency_file_name}"
  }

  file{ $log4j_config_file:
    ensure  => 'file',
    mode    => '0644',
    owner   => $owner,
    group   => $group,
    content => template('lightblue/application/migrator/log4j.properties.erb'),
  }

}
