require 'spec_helper'

describe 'lightblue::application::migrator' do
  service_name = 'migrator-service'
  client_config = 'lightblue-client.properties'
  metadata_uri = 'fake.metadata.uri'
  data_uri = 'fake.data.uri'
  
  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }
  
  let :facts do
    {
      :architecture => 'x86_64',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0'
    }
  end
    
  context 'defaults' do
    hostname = 'localhost'
    checker_name = 'test1'
    job_version = 1
    configuration_version = 1
    
    let :params do
      {
        :primary_client_metadata_uri => metadata_uri,
        :primary_client_data_uri => data_uri,
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
      
      should contain_file("/etc/init.d/#{service_name}") \
        .that_notifies("Service[#{service_name}]") \
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
  
  context 'with optional source and destination clients' do
    source_config = 'source.properties'
    source_metadata_url = 'fake.src.metadata.uri'
    source_data_url = 'fake.src.data.uri'
    
    destination_config = 'destination.properties'
    destination_metadata_url = 'fake.dest.metadata.uri'
    destination_data_url = 'fake.dest.data.uri'
    
    let :params do
      {
        :primary_client_metadata_uri => 'fake.metadata.uri',
        :primary_client_data_uri => 'fake.data.uri',
        :checker_name => 'test2',
        :hostname => 'localhost',
        :job_version => 1,
        :configuration_version => 1,
        :source_config => source_config,
        :source_client_metadata_uri => source_metadata_url,
        :source_client_data_uri => source_data_url,
        :destination_config => destination_config,
        :destination_client_metadata_uri => destination_metadata_url,
        :destination_client_data_uri => destination_data_url
      }
    end
    
    it do
      should contain_package('lightblue-consistency-checker').with(
        {
          :ensure => 'latest'
        }
      )
      
      should contain_file(client_config) \
        .that_notifies("Service[#{service_name}]") \
        .with_content(/^metadataServiceURI=#{metadata_uri}$/) \
        .with_content(/^dataServiceURI=#{data_uri}/)
      
      should contain_file(source_config) \
        .that_notifies("Service[#{service_name}]")\
        .with_content(/^metadataServiceURI=#{source_metadata_url}$/) \
        .with_content(/^dataServiceURI=#{source_data_url}/)
      
      should contain_file(destination_config) \
        .that_notifies("Service[#{service_name}]")\
        .with_content(/^metadataServiceURI=#{destination_metadata_url}$/) \
        .with_content(/^dataServiceURI=#{destination_data_url}/)
      
      should contain_file("/etc/init.d/#{service_name}") \
        .that_notifies("Service[#{service_name}]") \
        .with_content(/--config=#{client_config}/) \
        .with_content(/--sourceconfig=#{source_config}/) \
        .with_content(/--destinationconfig=#{destination_config}/)
      
      should contain_service(service_name).with({
        :ensure => 'running'
      })
    end
  end
  
  context 'with source config, but undefined metadata uri' do      
    let :params do
      {
        :primary_client_metadata_uri => 'fake.metadata.uri',
        :primary_client_data_uri => 'fake.data.uri',
        :checker_name => 'test2',
        :hostname => 'localhost',
        :job_version => 1,
        :configuration_version => 1,
        :source_config => 'source.properties',
        #:source_client_metadata_uri
        :source_client_data_uri => 'some uri'
      }
    end
    
    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /If defining a source_config, then you must also define data and metadata urls for it./)
    end
  end
  
  context 'with source config, but undefined data uri' do      
    let :params do
      {
        :primary_client_metadata_uri => 'fake.metadata.uri',
        :primary_client_data_uri => 'fake.data.uri',
        :checker_name => 'test2',
        :hostname => 'localhost',
        :job_version => 1,
        :configuration_version => 1,
        :source_config => 'source.properties',
        :source_client_metadata_uri => 'some uri'
        #:source_client_data_uri
      }
    end
    
    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /If defining a source_config, then you must also define data and metadata urls for it./)
    end
  end
  
  context 'with destination config, but undefined metadata uri' do      
    let :params do
      {
        :primary_client_metadata_uri => 'fake.metadata.uri',
        :primary_client_data_uri => 'fake.data.uri',
        :checker_name => 'test2',
        :hostname => 'localhost',
        :job_version => 1,
        :configuration_version => 1,
        :destination_config => 'destination.properties',
        #:destination_client_metadata_uri
        :destination_client_data_uri => 'some uri'
      }
    end
    
    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /If defining a destination_config, then you must also define data and metadata urls for it./)
    end
  end
  
  context 'with destination config, but undefined data uri' do      
    let :params do
      {
        :primary_client_metadata_uri => 'fake.metadata.uri',
        :primary_client_data_uri => 'fake.data.uri',
        :checker_name => 'test2',
        :hostname => 'localhost',
        :job_version => 1,
        :configuration_version => 1,
        :destination_config => 'destination.properties',
        :destination_client_metadata_uri => 'some uri'
        #:destination_client_data_uri
      }
    end
    
    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /If defining a destination_config, then you must also define data and metadata urls for it./)
    end
  end
  
end
