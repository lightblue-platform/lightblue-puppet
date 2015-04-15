require 'spec_helper'

describe 'lightblue::eap::mongossl' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  context 'no source' do
    let :params do
      {
        :certificate_file => '/tmp/certfile',
        :java_ks_password => 'password',
        :certificate_content => 'CONTENT',
        :certificate_source => ''
      }
    end

    it do
      should contain_file("/tmp/certfile") \
        .with({
            'ensure'  => 'file',
            'owner'   => 'jboss',
            'group'   => 'jboss',
            'mode'    => '0600'
          }
        ) \
        .with_content(/CONTENT/)
    end
  end

end
