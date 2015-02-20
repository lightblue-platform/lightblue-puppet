require 'spec_helper'

describe 'lightblue::service::plugin::statsd' do
  
  context 'deploy statsd.sh' do
    
    describe 'without prefix' do
      statsd_hostname = 'localhost'
      statsd_port = 1234
      
      let :params do
        {
          :hostname => statsd_hostname,
          :port     => statsd_port
        }
      end
      
      it do
        should contain_file('/etc/profile.d/lb-statsd.sh') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0755'
            }
          ) \
          .without_content(/^export STATSD_PREFIX=/) \
          .with_content(/^export STATSD_HOSTNAME=#{statsd_hostname}$/) \
          .with_content(/^export STATSD_PORT=#{statsd_port}$/)
      end
    end
    
    describe 'with prefix' do
      statsd_prefix = 'mister'
      
      let :params do
        {
          :hostname => 'localhost',
          :port     => 1234,
          :prefix   => statsd_prefix
        }
      end
      
      it do
        should contain_file('/etc/profile.d/lb-statsd.sh') \
        .with_content(/^export STATSD_PREFIX=#{statsd_prefix}$/)
      end
    end
  end
  
  context 'statsd.sh is absent' do    
    it do
      should contain_file('/etc/profile.d/lb-statsd.sh') \
        .with({
          'ensure' => 'absent'
        })
    end
  end
  
end
