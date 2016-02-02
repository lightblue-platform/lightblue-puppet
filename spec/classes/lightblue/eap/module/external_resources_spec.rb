require 'spec_helper'

describe 'lightblue::eap::module::external_resources' do

  context 'deploy external_resources.json' do
    let :params do
      {
        :directory          => '/tmp',
        :external_resources => ['fake.jar', 'fake/dir/']
      }
      
      it do
        should contain_file('/tmp/lightblue-external-resources.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"fake.jar"/)\
          .with_content(/"fake\/dir\/"/)
      end
    end
  end
  
end
