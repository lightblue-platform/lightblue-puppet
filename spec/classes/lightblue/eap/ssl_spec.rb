require 'spec_helper'

describe 'lightblue::eap::ssl' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  let :facts do
    {
      :architecture => 'x86_64'
    }
  end

  context 'defaults' do
    let :params do
      {
        :keystore_alias => 'keystore',
        :keystore_location => '/keystore',
        :keystore_password => 'password',
        :server_certificate_source => '/tmp/source',
        :server_certificate_file => '/certfile'
      }
    end

    it do
      should contain_file("/certfile")
      should contain_file("/keystore/eap6.keystore")
    end
  end

end
