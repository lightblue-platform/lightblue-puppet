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
  
  context 'customized variables' do
    log_level = 'DEBUG'
    log_file_name = 'mylogfile.log'
    log_max_file_size = '5MB'
    log_max_backups_to_keep = '20'
    log_pattern = 'some pattern'
    
    let :params do
      {
        :service_name => service_name,
        :config_dir => config_dir,
        :log_dir => log_dir,
        :owner => 'root',
        :group => 'root',
        :log_level => log_level,
        :log_file_name => log_file_name,
        :log_max_file_size => log_max_file_size,
        :log_max_backups_to_keep => log_max_backups_to_keep,
        :log_pattern => log_pattern,
      }
    end
    
    it do      
      should contain_file("#{config_dir}/log4j.properties") \
        .with_content(/^log4j.rootLogger=#{log_level},file$/) \
        .with_content(/^log4j.appender.file.File=#{log_dir}\/#{log_file_name}$/) \
        .with_content(/^log4j.appender.file.MaxFileSize=#{log_max_file_size}$/) \
        .with_content(/^log4j.appender.file.MaxBackupIndex=#{log_max_backups_to_keep}$/) \
        .with_content(/^log4j.appender.file.layout.ConversionPattern=#{log_pattern}$/)
    end
  end

end
