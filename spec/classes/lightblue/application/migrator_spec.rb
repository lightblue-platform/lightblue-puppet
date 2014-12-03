require 'spec_helper'

describe 'lightblue::application::migrator' do
  metadata_uri = 'fake.metadata.uri'
  data_uri = 'fake.data.uri'
  hostname = 'localhost'
  ip = '127.0.0.1'
  checker_name = 'frank'
  job_version = 1
  configuration_version = 1
  
  let(:hiera_config){'spec/fixtures/hiera/repo.yaml'}
  
  let :params do
    {
      :lbclient_metadata_uri => metadata_uri,
      :lbclient_data_uri => data_uri,
      :hostname => hostname,
      :ip => ip,
      :checker_name => checker_name,
      :job_version => job_version,
      :configuration_version => configuration_version,
      
      :lbclient_use_cert_auth => false,
      :lbclient_ca_file_path => nil,
      :lbclient_cert_file_path => nil,
      :lbclient_cert_password => nil,
      :lbclient_cert_alias => nil,
      :config_file => 'lightblue-client.properties',
      :service_owner => 'root',
      :service_group => 'root',
      :migrator_version => 'latest',
      :jsvc_version => 'latest',
      :java_home => nil,
      :jar_path => '/usr/share/jbossas/standalone/deployments/consistency-checker-*.jar',
      :service_log_file => 'migrator.log'
    }
  end
  
  it do
    should contain_package('lightblue-consistency-checker').with(
      {
        :ensure => 'latest'
      }
    )
  end
end
