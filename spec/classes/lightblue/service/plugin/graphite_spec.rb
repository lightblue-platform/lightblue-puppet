require 'spec_helper'

describe 'lightblue::service::plugin::graphite' do
  
  context 'deploy graphite.sh' do
    
    describe 'without prefix' do
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
          .without_content(/^export GRAPHITE_PREFIX=/) \
          .with_content(/^export GRAPHITE_HOSTNAME=#{graphite_hostname}$/) \
          .with_content(/^export GRAPHITE_PORT=#{graphite_port}$/)
      end
    end
    
    describe 'with prefix' do
      graphite_prefix = 'mister'
      
      let :params do
        {
          :hostname => 'localhost',
          :port     => 1234,
          :prefix   => graphite_prefix
        }
      end
      
      it do
        should contain_file('/etc/profile.d/graphite.sh') \
        .with_content(/^export GRAPHITE_PREFIX=#{graphite_prefix}$/)
      end
    end
  end
  
  context 'graphite.sh is absent' do
    it do
      should contain_file('/etc/profile.d/graphite.sh') \
        .with({
          'ensure' => 'absent'
        })
    end
  end
  
  context 'missing port' do
    let :params do
      {
        :hostname => 'localhost'
        #:port
      }
    end
    
    it do
      expect {
        should compile
      }.to raise_error(Puppet::Error, /If providing a graphite hostname, a port must also be provided./)
    end
  end
  
end
