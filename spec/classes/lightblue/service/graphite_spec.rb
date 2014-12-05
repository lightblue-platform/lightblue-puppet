require 'spec_helper'

describe 'lightblue::service::graphite' do
  graphite_hostname = 'localhost'
  graphite_port = 1234
  
  let :params do
    {
      :hostname => graphite_hostname,
      :port     => graphite_port
    }
  end
  
  it do
    should contain_file('/etc/profile.d/graphite.sh') \
      .with({
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755'
        }
      ) \
      .with_content(/^export GRAPHITE_HOSTNAME=#{graphite_hostname}$/) \
      .with_content(/^export GRAPHITE_PORT=#{graphite_port}$/)
  end
end
