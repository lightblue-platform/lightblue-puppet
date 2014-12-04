require 'spec_helper'

describe 'lightblue::application::migrator' do
  service_name = 'migrator-service'
  client_config = 'lightblue-client.properties'
  
  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }
  
  let :facts do
    {
      :architecture => 'x86_64',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0'
    }
  end
    
  context 'defaults' do
    metadata_uri = 'fake.metadata.uri'
    data_uri = 'fake.data.uri'
    hostname = 'localhost'
    checker_name = 'test1'
    job_version = 1
    configuration_version = 1
    
    let :params do
      {
        :lbclient_metadata_uri => metadata_uri,
        :lbclient_data_uri => data_uri,
        :checker_name => checker_name,
        :hostname => hostname,
        :job_version => job_version,
        :configuration_version => configuration_version
      }
    end
    
    it do
      should contain_package('lightblue-consistency-checker').with(
        {
          :ensure => 'latest'
        }
      )
      
      should contain_file(client_config).that_notifies("Service[#{service_name}]")
      
      should contain_file("/etc/init.d/#{service_name}").that_notifies("Service[#{service_name}]") \
        .with_content(/--name=#{checker_name}/) \
        .with_content(/--hostname=#{hostname}/) \
        .with_content(/--config=#{client_config}/) \
        .with_content(/--configversion=#{configuration_version}/) \
        .with_content(/--jobversion=#{job_version}/) \
        .with_content(/--sourceconfig=#{client_config}/) \
        .with_content(/--destinationconfig=#{client_config}/)
      
      should contain_service(service_name).with({
        :ensure => 'running'
      })
    end
  end
  
  context 'with optional settings' do
    source_config = 'source.properties'
    destination_config = 'properties'
    
    let :params do
      {
        :lbclient_metadata_uri => 'fake.metadata.uri',
        :lbclient_data_uri => 'fake.data.uri',
        :checker_name => 'test2',
        :hostname => 'localhost',
        :job_version => 1,
        :configuration_version => 1,
        :source_config => source_config,
        :destination_config => destination_config
      }
    end
    
    it do
      should contain_package('lightblue-consistency-checker').with(
        {
          :ensure => 'latest'
        }
      )
      
      should contain_file(client_config).that_notifies("Service[#{service_name}]")
      
      should contain_file("/etc/init.d/#{service_name}").that_notifies("Service[#{service_name}]") \
        .with_content(/--config=#{client_config}/) \
        .with_content(/--sourceconfig=#{source_config}/) \
        .with_content(/--destinationconfig=#{destination_config}/)
      
      should contain_service(service_name).with({
        :ensure => 'running'
      })
    end
  end
  
end
