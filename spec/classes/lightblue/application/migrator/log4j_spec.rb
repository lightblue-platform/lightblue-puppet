require 'spec_helper'

describe 'lightblue::application::migrator::log4j' do
  
  service_name = 'fake-service'
  config_dir = '/etc/migrator'
  log_dir = '/var/log/migrator'
  
  context 'defaults' do
    let :params do
      {
        :service_name => service_name,
        :config_dir => config_dir,
        :log_dir => log_dir,
        :owner => 'root',
        :group => 'root',
      }
    end
    
    it do      
      should contain_file("#{config_dir}/log4j.properties").with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      }) \
        .with_content(/^log4j.rootLogger=INFO,file$/) \
        .with_content(/^log4j.appender.file.File=#{log_dir}\/migrator.log$/) \
        .with_content(/^log4j.appender.file.MaxFileSize=1MB$/) \
        .with_content(/^log4j.appender.file.MaxBackupIndex=5$/) \
        .with_content(/^log4j.appender.file.layout.ConversionPattern=\%d \[\%t\] \%c \%p - \%m\%n$/) \
        .with_notify("Service[#{service_name}]")
    end
  end

end
