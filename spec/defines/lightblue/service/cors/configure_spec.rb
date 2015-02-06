require 'spec_helper'

describe 'lightblue::service::cors::configure' do
  config_file = 'lightblue-cors.json'

  let(:title){config_file}

  context 'with all fields defined' do
    let :params do
      {
        :url_patterns => ['/test', '/data/*'],
        :allowed_origins => ['origin1', 'origin2'],
        :allowed_methods => ['GET', 'HEAD'],
        :allowed_headers => ['header1', 'header2'],
        :exposed_headers => ['header3', 'header4', 'header5'],
        :allow_credentials => true,
        :preflight_max_age => 1000,
        :enable_logging => true
      }
    end

    it do
      should contain_file(config_file) \
      .with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      }) \
        .with_content(/^\s*"urlPatterns": \["\/test", "\/data\/\*"\],$/) \
        .with_content(/^\s*"allowedOrigins": \["origin1", "origin2"\],$/) \
        .with_content(/^\s*"allowedMethods": \["GET", "HEAD"\],$/) \
        .with_content(/^\s*"allowedHeaders": \["header1", "header2"\],$/) \
        .with_content(/^\s*"exposedHeaders": \["header3", "header4", "header5"\],$/) \
        .with_content(/^\s*"allowCredentials": true,$/) \
        .with_content(/^\s*"preflightMaxAge": 1000,$/) \
        .with_content(/^\s*"enableLogging": true,$/)
    end
  end

  context 'with no fields defined' do
    it do
      should contain_file(config_file).with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      }) \
        .without_content(/^\s*"urlPatterns":/) \
        .without_content(/^\s*"allowedOrigins":/) \
        .without_content(/^\s*"allowedMethods":/) \
        .without_content(/^\s*"allowedHeaders":/) \
        .without_content(/^\s*"exposedHeaders":/) \
        .without_content(/^\s*"allowCredentials":/) \
        .without_content(/^\s*"preflightMaxAge":/) \
        .without_content(/^\s*"enableLogging":/)
    end
  end

end
