require 'spec_helper'

describe 'lightblue::eap::mongossl' do

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

    it do
      #should contain_file("/cacert")
      #should contain_file("/keystore/cacerts")
    end
  end

end
