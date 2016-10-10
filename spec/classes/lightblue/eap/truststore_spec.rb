require 'spec_helper'

describe 'lightblue::eap::truststore' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  let :facts do
    {
      :architecture => 'x86_64'
    }
  end

  context 'defaults' do
    let :certificates do
      {
          "name" => "cacert",
          "source" => "puppet:///modules/certificates/cacert",
          "file" => "/cacert"
      }
    end
    let :params do
      {
        :keystore_alias => 'keystore',
        :keystore_location => '/keystore',
        :keystore_password => 'password',
        :certificates => certificates
      }
    end

    it do
      #should contain_file("/cacert")
      #should contain_file("/keystore/eap6trust.keystore")
    end
  end

end
