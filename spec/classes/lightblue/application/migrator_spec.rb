require 'spec_helper'

describe 'lightblue::application::migrator' do
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
  end
end
