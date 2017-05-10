require 'spec_helper'

describe 'lightblue::eap::module::datasources' do

  context 'deploy datasources.json' do

    describe 'standard' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_no_cert_validation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false
        }
      end

      it do
        should contain_file('/tmp/datasources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .without_content(/"writeConcern"/)
      end

    end

    describe 'metadata write_concern' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_no_cert_validation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_metadata_write_concern => 'majority'
        }
      end

      it do
        should contain_file('/tmp/datasources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"writeConcern": "majority"/) 
      end

    end

    describe 'metadata max_result_set_size' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_no_cert_validation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_max_result_set_size => 999,
          :mongo_metadata_write_concern => 'majority'
        }
      end

      it do
        should contain_file('/tmp/datasources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"maxResultSetSize" : 999/)
      end

    end

    describe 'data write_concern' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_no_cert_validation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_data_write_concern => 'majority'
        }
      end

      it do
        should contain_file('/tmp/datasources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"writeConcern": "majority"/) 
      end

    end

    describe 'data max_query_time_ms' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_no_cert_validation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_data_max_query_time_ms => 50000
        }
      end

      it do
        should contain_file('/tmp/datasources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"max_query_time_ms": "50000"/) 
      end

    end

    describe 'metadata and data write_concern' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_no_cert_validation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_metadata_write_concern => 'majority',
          :mongo_data_write_concern => 'fsynced'
        }
      end

      it do
        should contain_file('/tmp/datasources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"writeConcern": "majority"/) \
          .with_content(/"writeConcern": "fsynced"/) 
      end

    end


    describe 'ldap' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_no_cert_validation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :ldap_config => [{
              'datasourceName' => 'ldap',
              'database' => 'db',
              'bindabledn' => 'uid=admin,dc=example,dc=com',
              'password' => 'passwd',
              'numberOfInitialConnections' => '5',
              'maxNumberOfConnections' => '10',
              'servers' => [{
                'host' => 'localhost',
                'port' => '456'
              }]
          }]
        }
      end

      it do
        should contain_file('/tmp/datasources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"ldap":/) \
          .with_content(/"database": "db"/) \
          .with_content(/"bindabledn": "uid=admin,dc=example,dc=com"/) \
          .with_content(/"password": "passwd"/) \
          .with_content(/"numberOfInitialConnections": 5/)\
          .with_content(/"maxNumberOfConnections": 10/) \
          .with_content(/"servers":/) \
          .with_content(/"host": "localhost"/) \
          .with_content(/"port": "456"/)
      end

    end

  end

end
