# Installs RDBMS data sources
class lightblue::service::plugin::rdbms (
    $rdbms_servers_cfg = undef,
) {

  if $rdbms_servers_cfg.kind_of?(Array) {
    $rdbms_servers_cfg.each |$server| {
      if $server['dbms'] == 'oracle' {
        $driver_name = 'oracle'
        $driver-module-name" = 'oracle.jdbcx'
        $driver-xa-datasource-class-name" = 'oracle.jdbc.XADataSource'
        lightblue::jcliff::config { 'lightblue-rdbms-oracle-driver.conf':
          content => template('lightblue/lightblue-rdbms-oracle-driver.conf.erb')
        }
      }

      $data_source_name = $server['data_source_name']
      $jndi-name = $server['jndi_name']
      $connection-url = $server['connection_url']
      $driver-name = $server['driver_name']
      $user-name = $server['user_name']
      $password = $server['password']
      $min_conn = $server['min_conn']
      $max_conn = $server['max_conn']

      lightblue::jcliff::config { 'lightblue-rdbms-datasource.conf':
        content => template('lightblue/lightblue-rdbms-datasource.conf.erb')
      }
    }
  }
}