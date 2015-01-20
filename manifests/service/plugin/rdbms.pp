# Installs RDBMS data sources
class lightblue::service::plugin::rdbms (
  $driver_name,
  $driver_module_name,
  $driver_xa_datasource_class_name,
  $data_source_name,
  $jndi_name,
  $connection_url,
  $user_name,
  $password,
  $min_conn,
  $max_conn,
) {

  lightblue::jcliff::config { 'lightblue-rdbms-driver.conf':
    content => template('lightblue/lightblue-rdbms-driver.conf.erb')
  }

  lightblue::jcliff::config { 'lightblue-rdbms-datasource.conf':
    content => template('lightblue/lightblue-rdbms-datasource.conf.erb')
  }
}
