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
          )
      end

    end

  end

end
