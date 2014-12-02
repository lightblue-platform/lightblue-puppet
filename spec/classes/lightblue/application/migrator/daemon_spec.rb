require 'spec_helper'

describe 'lightblue::application::migrator::daemon' do

  context 'fake os' do
    fake_os_name = 'fakeos'

    let :facts do
      {
        :osfamily => fake_os_name
      }
    end

    it do
      expect{
        to raise_error(Puppet::Error, /Unsupported OS family: #{fake_os_name}/)
      }
    end
  end

  context 'rhel6 jsvc package' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystemrelease => '6.0'
      }
    end
    
    let :params do
      {
        :service_name => 'fake_service',
        :service_out_logfile => 'out.log',
        :service_err_logfile => 'err.log',
        :jar_path => '/path/to/jar',
        :mainClass => 'Main.class'
      }
    end

    it do
      should contain_package('jakarta-commons-daemon-jsvc').with(
        {
          :ensure => 'latest'
        }
      )
    end
  end

  context 'rhel7 jsvc package' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7.0'
      }
    end
    
    let :params do
      {
        :service_name => 'fake_service',
        :service_out_logfile => 'out.log',
        :service_err_logfile => 'err.log',
        :jar_path => '/path/to/jar',
        :mainClass => 'Main.class'
      }
    end
    
    it do
      should contain_package('apache-commons-daemon-jsvc').with(
        {
          :ensure => 'latest'
        }
      )
    end
  end
  
  context 'daemon.sh' do
    service_name = 'fake_service'
    path_to_jar = '/path/to/jar'
    main_class = 'Main.class'
    log_out = 'out.log'
    log_err = 'err.log'
    
    let :facts do
      {
        :osfamily => 'RedHat',
        :operatingsystemrelease => '7.0'
      }
    end
    
    describe 'with default settings' do
      let :params do
        {
          :service_name => service_name,
          :service_out_logfile => log_out,
          :service_err_logfile => log_err,
          :jar_path => path_to_jar,
          :mainClass => main_class
        }
      end
      
      it do
        should contain_file("/etc/init.d/#{service_name}").with({
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0744',
        }) \
        .with_content(/^JSVC_EXEC=\$\(which jsvc\)$/) \
        .without_content(/^JAVA_HOME_DIR=*$/) \
        .without_content(/^LIBS=*$/) \
        .with_content(/^MAIN_CLASS=#{main_class}$/) \
        .with_content(/^PID=\/tmp\/#{service_name}.pid$/) \
        .with_content(/^LOG_OUT=#{log_out}$/) \
        .with_content(/^LOG_ERR=#{log_err}$/) \
        .with_content(/#{path_to_jar}/)
      end
    end
    
  end

end
