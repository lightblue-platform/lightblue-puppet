require 'spec_helper'

describe 'lightblue::eap::module::datasources' do

  context 'deploy datasources.json' do

    describe 'standard' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_noCertValidation => true,
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

    describe 'metadata writeConcern' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_noCertValidation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_metadata_writeConcern => 'majority'
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

    describe 'data writeConcern' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_noCertValidation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_data_writeConcern => 'majority'
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

    describe 'metadata and data writeConcern' do

      let :params do
        {
          :directory => '/tmp',
          :mongo_noCertValidation => true,
          :mongo_auth_mechanism => 'MONGODB_CR_MECHANISM',
          :mongo_auth_source => 'admin',
          :mongo_auth_username => 'lightblue',
          :mongo_auth_password => 'nothing',
          :mongo_ssl => false,
          :mongo_metadata_writeConcern => 'majority',
          :mongo_data_writeConcern => 'fsynced'
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
          :mongo_noCertValidation => true,
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
