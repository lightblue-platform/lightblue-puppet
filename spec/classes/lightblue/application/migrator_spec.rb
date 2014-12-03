require 'spec_helper'

describe 'lightblue::application::migrator' do
  service_name = 'migrator-service'
  metadata_uri = 'fake.metadata.uri'
  data_uri = 'fake.data.uri'
  hostname = 'localhost'
  ip = '127.0.0.1'
  checker_name = 'frank'
  job_version = 1
  configuration_version = 1
  
  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }
  
  let :facts do
    {
      :architecture => 'x86_64',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0'
    }
  end
    
  let :params do
    {
      :lbclient_metadata_uri => metadata_uri,
      :lbclient_data_uri => data_uri,
      :hostname => hostname,
      :ip => ip,
      :checker_name => checker_name,
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
    
    should contain_file('lightblue-client.properties').that_notifies("Service[#{service_name}]")
    should contain_file("/etc/init.d/#{service_name}").that_notifies("Service[#{service_name}]") \
      .with_content(/--hostname=#{hostname}/) \
      .with_content(/--ip=#{ip}/) \
      .with_content(/--name=#{checker_name}/) \
      .with_content(/--jobversion=#{job_version}/) \
      .with_content(/--configversion=#{configuration_version}/)
    
    should contain_service(service_name).with({
      :ensure => 'running'
    })
  end
end
