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
      should contain_package('lightblue-migrator-consistency-checker').with(
        {
          :ensure => 'latest'
        }
      )
      
      should contain_lightblue__client__configure(client_config) \
        .that_notifies("Service[#{service_name}]")
      
      should contain_file("/etc/init.d/#{service_name}") \
        .with_content(/--name=#{checker_name}/) \
        .with_content(/--hostname=#{hostname}/) \
        .with_content(/--config=#{client_config}/) \
        .with_content(/--configversion=#{configuration_version}/) \
        .with_content(/--jobversion=#{job_version}/) \
        .with_content(/--sourceconfig=#{client_config}/) \
        .with_content(/--destinationconfig=#{client_config}/) \
        .that_notifies("Service[#{service_name}]")
        
      should contain_service(service_name).with({
        :ensure => 'running'
      })
    end
  end
  
  context 'with ca and cert' do
    ca_path = '/some/path/to/ca'
    cert_path = '/some/path/to/cert'
    
    describe 'both present' do
      ca_source = 'ca source data'
      cert_source = 'cert source data'
      
      let :params do
        {
          :primary_client_metadata_uri => metadata_uri,
          :primary_client_data_uri => data_uri,
          :checker_name => 'fakename',
          :hostname => 'localhost',
          :job_version => 1,
          :configuration_version => 1,
          :primary_client_use_cert_auth => true,
          :primary_client_ca_file_path => ca_path,
          :primary_client_ca_source => ca_source,
          :primary_client_cert_file_path => cert_path,
          :primary_client_cert_source => cert_source
        }
      end
      
      it do
        should contain_file(ca_path) \
          .with({
            :mode    => '0644',
            :owner   => 'root',
            :group   => 'root',
            :links   => 'follow',
            :source  => ca_source
          }) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_file(cert_path) \
          .with({
            :mode    => '0644',
            :owner   => 'root',
            :group   => 'root',
            :links   => 'follow',
            :source  => cert_source
          }) \
          .that_notifies("Service[#{service_name}]")
      end
    end
    
    describe 'but ca file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => metadata_uri,
          :primary_client_data_uri => data_uri,
          :checker_name => 'fakename',
          :hostname => 'localhost',
          :job_version => 1,
          :configuration_version => 1,
          :primary_client_use_cert_auth => true,
          :primary_client_ca_source => 'fake source data',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/Must provide \$primary_client_ca_file_path in order to deploy ca file./)
      end
    end
    
    describe 'but cert file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => metadata_uri,
          :primary_client_data_uri => data_uri,
          :checker_name => 'fakename',
          :hostname => 'localhost',
          :job_version => 1,
          :configuration_version => 1,
          :primary_client_use_cert_auth => true,
          :primary_client_cert_source => 'fake source data',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/Must provide \$primary_client_cert_file_path in order to deploy cert file./)
      end
    end
  end
  
  context 'with optional source and destination clients' do
    source_config = 'source.properties'
    destination_config = 'destination.properties'
    
    describe 'both present' do
      source_metadata_url = 'fake.src.metadata.uri'
      source_data_url = 'fake.src.data.uri'
      source_ca_path = '/some/path/to/source/ca'
      source_cert_path = '/some/path/to/source/cert'
      source_ca_content = 'fake source ca content'
      source_cert_content = 'fake source cert content'
      
      destination_metadata_url = 'fake.dest.metadata.uri'
      destination_data_url = 'fake.dest.data.uri'
      destination_ca_path = '/some/path/to/dest/ca'
      destination_cert_path = '/some/path/to/dest/cert'
      destination_ca_content = 'fake destination ca content'
      destination_cert_content = 'fake destination cert content'
      
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
          :source_client_use_cert_auth => true,
          :source_client_ca_file_path => source_ca_path,
          :source_client_ca_source => source_ca_content,
          :source_client_cert_file_path => source_cert_path,
          :source_client_cert_source => source_cert_content,
          :destination_config => destination_config,
          :destination_client_metadata_uri => destination_metadata_url,
          :destination_client_data_uri => destination_data_url,
          :destination_client_use_cert_auth => true,
          :destination_client_ca_file_path => destination_ca_path,
          :destination_client_ca_source => destination_ca_content,
          :destination_client_cert_file_path => destination_cert_path,
          :destination_client_cert_source => destination_cert_content
        }
      end
      
      it do
        should contain_package('lightblue-migrator-consistency-checker').with(
          {
            :ensure => 'latest'
          }
        )
        
        should contain_lightblue__client__configure(client_config) \
         .with({
            :lbclient_metadata_uri   => metadata_uri,
            :lbclient_data_uri       => data_uri,
          }) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_lightblue__client__configure(source_config) \
         .with({
            :lbclient_metadata_uri   => source_metadata_url,
            :lbclient_data_uri       => source_data_url,
         }) \
         .that_notifies("Service[#{service_name}]")
        
        should contain_file(source_ca_path) \
          .with({
            :mode    => '0644',
            :owner   => 'root',
            :group   => 'root',
            :links   => 'follow',
            :source  => source_ca_content
          }) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_file(source_cert_path) \
          .with({
            :mode    => '0644',
            :owner   => 'root',
            :group   => 'root',
            :links   => 'follow',
            :source  => source_cert_content
          }) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_lightblue__client__configure(destination_config) \
          .with({
            :lbclient_metadata_uri   => destination_metadata_url,
            :lbclient_data_uri       => destination_data_url,
          }) \
          .that_notifies("Service[#{service_name}]")
          
        should contain_file(destination_ca_path) \
          .with({
            :mode    => '0644',
            :owner   => 'root',
            :group   => 'root',
            :links   => 'follow',
            :source  => destination_ca_content
          }) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_file(destination_cert_path) \
          .with({
            :mode    => '0644',
            :owner   => 'root',
            :group   => 'root',
            :links   => 'follow',
            :source  => destination_cert_content
          }) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_file("/etc/init.d/#{service_name}") \
          .with_content(/--config=#{client_config}/) \
          .with_content(/--sourceconfig=#{source_config}/) \
          .with_content(/--destinationconfig=#{destination_config}/) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_service(service_name).with({
          :ensure => 'running'
        })
      end
    end
    
    describe 'but source ca file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :job_version => 1,
          :configuration_version => 1,
          :source_client_metadata_uri => 'fake.src.metadata.uri',
          :source_client_data_uri => 'fake.src.data.uri',
          :source_client_use_cert_auth => true,
          :source_config => source_config,
          :source_client_ca_source => 'fake content'
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/Must provide \$source_client_ca_file_path in order to deploy source ca file./)
      end
    end
    
    describe 'but source cert file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :job_version => 1,
          :configuration_version => 1,
          :source_client_metadata_uri => 'fake.src.metadata.uri',
          :source_client_data_uri => 'fake.src.data.uri',
          :source_client_use_cert_auth => true,
          :source_config => source_config,
          :source_client_cert_source => 'fake content'
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/Must provide \$source_client_cert_file_path in order to deploy source cert file./)
      end
    end
    
    describe 'but destination ca file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :job_version => 1,
          :configuration_version => 1,
          :destination_client_metadata_uri => 'fake.dest.metadata.uri',
          :destination_client_data_uri => 'fake.dest.data.uri',
          :destination_client_use_cert_auth => true,
          :destination_config => destination_config,
          :destination_client_ca_source => 'fake content'
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/Must provide \$destination_client_ca_file_path in order to deploy destination ca file./)
      end
    end
    
    describe 'but destination cert file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :job_version => 1,
          :configuration_version => 1,
          :destination_client_metadata_uri => 'fake.dest.metadata.uri',
          :destination_client_data_uri => 'fake.dest.data.uri',
          :destination_client_use_cert_auth => true,
          :destination_config => destination_config,
          :destination_client_cert_source => 'fake content'
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/Must provide \$destination_client_cert_file_path in order to deploy destination cert file./)
      end
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
      }.to raise_error(/If defining a source_config, then you must also define data and metadata urls for it./)
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
      }.to raise_error(/If defining a source_config, then you must also define data and metadata urls for it./)
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
      }.to raise_error(/If defining a destination_config, then you must also define data and metadata urls for it./)
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
      }.to raise_error(/If defining a destination_config, then you must also define data and metadata urls for it./)
    end
  end
  
end
