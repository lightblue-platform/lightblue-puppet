require 'spec_helper'

describe 'lightblue::client::configure' do
  config_file = 'lightblue-client.properties'
  metadata_uri = 'fake.metadata.uri'
  data_uri = 'fake.data.uri'
  
  let(:title){config_file}
  
  context 'useCertAuth=false' do
    let :params do
      {
        :lbclient_metadata_uri => metadata_uri,
        :lbclient_data_uri => data_uri
      }
    end
  
    it do 
      should contain_file(config_file) \
      .with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      }) \
      .with_content(/^metadataServiceURI=#{metadata_uri}$/) \
      .with_content(/^dataServiceURI=#{data_uri}/) \
      .with_content(/^useCertAuth=false/)
    end
  end
  
  context 'useCertAuth=true' do
    ca_file_path = '/some/file/path/to/ca'
    cert_file_path = '/some/file/path/to/cert'
    password = 'secret'
    cert_alias = 'redleader'
    
    let :params do
      {
        :lbclient_metadata_uri => metadata_uri,
        :lbclient_data_uri => data_uri,
        :lbclient_use_cert_auth => true,
        :lbclient_ca_file_path => ca_file_path,
        :lbclient_cert_file_path => cert_file_path,
        :lbclient_cert_password => password,
        :lbclient_cert_alias => cert_alias
      }
    end
    
    it do 
      should contain_file(config_file).with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      }) \
      .with_content(/^metadataServiceURI=#{metadata_uri}$/) \
      .with_content(/^dataServiceURI=#{data_uri}/) \
      .with_content(/^useCertAuth=true/) \
      .with_content(/^caFilePath=#{ca_file_path}/) \
      .with_content(/^certFilePath=#{cert_file_path}/) \
      .with_content(/^certPassword=#{password}/) \
      .with_content(/^certAlias=#{cert_alias}/)
    end
  end

end
