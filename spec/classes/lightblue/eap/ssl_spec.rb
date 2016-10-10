require 'spec_helper'

describe 'lightblue::eap::ssl' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  let :facts do
    {
      :architecture => 'x86_64'
    }
  end

  context 'defaults' do
    let :certificates do
      {
          "name" => "lightblue.io",
          "source" => "puppet:///modules/certificates/lightblue.io",
          "file" => "/lightblue.io"
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
      #should contain_file("/certfile")
      #should contain_file("/keystore/eap6.keystore")
    end
  end

end
