# Installs an RDBMS data source
class lightblue::service::plugin::rdbms (
    $dbms = 'oracle',
    $data_source_name = 'rdbms',
    $jndi_name = 'java:/rdbms',
    $connection_url = 'jdbc:oracle:oci@db',
    $user_name = 'user',
    $password = 'password',
) {

  include lightblue::eap

  if $dbms == 'oracle' {
    $driver_name = 'oracle'

    lightblue::jcliff::config { 'lightblue-rdbms-oracle-driver.conf':
      content => template('lightblue/lightblue-rdbms-oracle-driver.conf.erb')
    }
  }

  lightblue::jcliff::config { 'lightblue-rdbms-datasource.conf':
    content => template('lightblue/lightblue-rdbms-datasource.conf.erb')
  }

}
