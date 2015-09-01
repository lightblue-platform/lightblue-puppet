require 'spec_helper'

describe 'lightblue::application::migrator' do
  service_name = 'migrator-service'
  client_config = '/etc/lightblue-migrator/primary-lightblue-client.properties'
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
    
    let :params do
      {
        :primary_client_metadata_uri => metadata_uri,
        :primary_client_data_uri => data_uri,
        :checker_name => checker_name,
        :hostname => hostname,
      }
    end
    
    it do
      should contain_package('lightblue-migrator').with(
        {
          :ensure => 'latest'
        }
      )
      
      should contain_lightblue__client__configure(client_config).with({
          :lbclient_use_cert_auth  => false,
        }) \
        .that_notifies("Service[#{service_name}]")
      
      should contain_file("/etc/init.d/#{service_name}") \
        .with_content(/--name=#{checker_name}/) \
        .with_content(/--hostname=#{hostname}/) \
        .with_content(/--config=#{client_config}/) \
        .that_notifies("Service[#{service_name}]")
      
      should contain_class('lightblue::application::migrator::daemon').with({
        :jvmOptions => []
      })
        
      should contain_service(service_name).with({
        :ensure => 'running'
      })
    end
  end
  
  context 'with a user provided ca and cert' do
    ca_path = '/some/path/to/ca'
    cert_path = '/some/path/to/primary.cert'
    
    describe 'both present' do
      ca_source = 'ca source data'
      cert_source = '/path/to/primary.cert'
      
      let :params do
        {
          :primary_client_metadata_uri => metadata_uri,
          :primary_client_data_uri => data_uri,
          :checker_name => 'fakename',
          :hostname => 'localhost',
          :primary_client_use_cert_auth => true,
          :primary_client_ca_file_path => ca_path,
          :primary_client_cert_file_path => cert_path,
        }
      end
      
      it do
        should contain_lightblue__client__configure(client_config) \
          .with({
            :lbclient_use_cert_auth  => true,
            :lbclient_ca_file_path   => "file://" + ca_path,
            :lbclient_cert_file_path => "file://" + cert_path,
          }) \
          .that_notifies("Service[#{service_name}]")
      end
    end
    
    describe 'but ca file path is missing' do
      let :params do
        {
          :primary_client_metadata_uri => metadata_uri,
          :primary_client_data_uri => data_uri,
          :checker_name => 'fakename',
          :hostname => 'localhost',
          :primary_client_use_cert_auth => true,
          :primary_client_cert_file_path => '/my/own.cert',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/If using your own primary migrator ca then the \$primary_client_ca_file_path must be provided./)
      end
    end
    
    describe 'but cert file path is missing' do
      let :params do
        {
          :primary_client_metadata_uri => metadata_uri,
          :primary_client_data_uri => data_uri,
          :checker_name => 'fakename',
          :hostname => 'localhost',
          :primary_client_use_cert_auth => true,
          :primary_client_ca_file_path => '/my/own.ca',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/If using your own primary migrator cert then the \$primary_client_cert_file_path must be provided./)
      end
    end
  end
  
  context 'with optional source and destination clients' do
    source_config = '/etc/lightblue-migrator/source-lightblue-client.properties'
    destination_config = '/etc/lightblue-migrator/destination-lightblue-client.properties'
    
    describe 'both present' do
      source_metadata_url = 'fake.src.metadata.uri'
      source_data_url = 'fake.src.data.uri'
      source_ca_path = '/etc/lightblue-migrator/source-lightblue.pem'
      source_cert_path = '/etc/lightblue-migrator/source.cert'
      source_ca_content = 'fake source ca content'
      source_cert_content = '/path/to/source.cert'
      
      destination_metadata_url = 'fake.dest.metadata.uri'
      destination_data_url = 'fake.dest.data.uri'
      destination_ca_path = '/etc/lightblue-migrator/destination-lightblue.pem'
      destination_cert_path = '/etc/lightblue-migrator/destination.cert'
      destination_ca_content = 'fake destination ca content'
      destination_cert_content = '/path/to/destination.cert'
      
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :is_source_same_as_primary => false,
          :source_client_metadata_uri => source_metadata_url,
          :source_client_data_uri => source_data_url,
          :source_client_use_cert_auth => true,
          :source_client_ca_source => source_ca_content,
          :source_client_cert_source => source_cert_content,
          :is_destination_same_as_primary => false,
          :destination_client_metadata_uri => destination_metadata_url,
          :destination_client_data_uri => destination_data_url,
          :destination_client_use_cert_auth => true,
          :destination_client_ca_source => destination_ca_content,
          :destination_client_cert_source => destination_cert_content
        }
      end
      
      it do
        should contain_package('lightblue-migrator').with(
          {
            :ensure => 'latest'
          }
        )
        
        should contain_lightblue__client__configure(client_config) \
         .with({
            :lbclient_metadata_uri   => metadata_uri,
            :lbclient_data_uri       => data_uri,
            :lbclient_use_cert_auth  => false,
          }) \
          .that_notifies("Service[#{service_name}]")
        
        should contain_lightblue__client__configure(source_config) \
         .with({
            :lbclient_metadata_uri   => source_metadata_url,
            :lbclient_data_uri       => source_data_url,
            :lbclient_use_cert_auth  => true,
            :lbclient_ca_file_path   => source_ca_path,
            :lbclient_cert_file_path => source_cert_path,
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
            :lbclient_use_cert_auth  => true,
            :lbclient_ca_file_path   => destination_ca_path,
            :lbclient_cert_file_path => destination_cert_path,
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
          .that_notifies("Service[#{service_name}]")
        
        should contain_class('lightblue::application::migrator::daemon').with({
        })
          
        should contain_service(service_name).with({
          :ensure => 'running'
        })
      end
    end
    
    describe 'with a user provided source ca and cert, but source ca file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :is_source_same_as_primary => false,
          :source_client_metadata_uri => 'fake.src.metadata.uri',
          :source_client_data_uri => 'fake.src.data.uri',
          :source_client_use_cert_auth => true,
          :source_client_cert_file_path => '/my/own.cert',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/If using your own source ca then the \$source_client_ca_file_path must be provided./)
      end
    end
    
    describe 'with a user provided source ca and cert, but source cert file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :is_source_same_as_primary => false,
          :source_client_metadata_uri => 'fake.src.metadata.uri',
          :source_client_data_uri => 'fake.src.data.uri',
          :source_client_use_cert_auth => true,
          :source_client_ca_file_path => '/my/own.ca',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/If using your own source cert then the \$source_client_cert_file_path must be provided./)
      end
    end
    
    describe 'with a user provided source ca and cert, but destination ca file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :is_destination_same_as_primary => false,
          :destination_client_metadata_uri => 'fake.dest.metadata.uri',
          :destination_client_data_uri => 'fake.dest.data.uri',
          :destination_client_use_cert_auth => true,
          :destination_client_cert_file_path => '/my/own.cert',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/If using your own destination ca then the \$destination_client_ca_file_path must be provided./)
      end
    end
    
    describe 'with a user provided source ca and cert, but destination cert file name is missing' do
      let :params do
        {
          :primary_client_metadata_uri => 'fake.metadata.uri',
          :primary_client_data_uri => 'fake.data.uri',
          :checker_name => 'test2',
          :hostname => 'localhost',
          :is_destination_same_as_primary => false,
          :destination_client_metadata_uri => 'fake.dest.metadata.uri',
          :destination_client_data_uri => 'fake.dest.data.uri',
          :destination_client_use_cert_auth => true,
          :destination_client_ca_file_path => '/my/own.ca',
        }
      end
      
      it do
        expect {
          should compile
        }.to raise_error(/If using your own destination cert then the \$destination_client_cert_file_path must be provided./)
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
        :is_source_same_as_primary => false,
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
        :is_source_same_as_primary => false,
        :source_client_metadata_uri => 'some uri'
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
        :is_destination_same_as_primary => false,
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
        :is_destination_same_as_primary => false,
        :destination_client_metadata_uri => 'some uri'
      }
    end
    
    it do
      expect {
        should compile
      }.to raise_error(/If defining a destination_config, then you must also define data and metadata urls for it./)
    end
  end
  
  context 'with log4j configured' do
    existing_jvm_option = 'somearg'
    
    let :params do
      {
        :primary_client_metadata_uri => 'fake.metadata.uri',
        :primary_client_data_uri => 'fake.data.uri',
        :checker_name => 'test2',
        :hostname => 'localhost',
        :generate_log4j => true,
        :serviceJvmOptions => [existing_jvm_option]
      }
    end
    
    it do
      should contain_class('lightblue::application::migrator::log4j').with({
        :config_dir => '/etc/lightblue-migrator',
        :log_dir => '/var/log/lightblue-migrator',
        :owner => 'root',
        :group => 'root',
      }) \
        .that_requires('File[/etc/lightblue-migrator]')
      
      #TODO rspec always thinks jvmOptions is [], not sure why
      should contain_class('lightblue::application::migrator::daemon').with({
        #:jvmOptions => ['Dlog4j.configuration=file:/etc/migrator/log4j.properties', existing_jvm_option]
      })
    end
  end
  
end
