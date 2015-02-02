require 'spec_helper'

describe 'lightblue::eap::module::cors::data' do
  context 'when config is defined' do
    directory = 'testdir'
    config = {
      'url_patterns'      => ['/data/*'],
      'allowed_origins'   => ['origin1', 'origin2'],
      'allowed_methods'   => ['GET', 'POST'],
      'allowed_headers'   => ['header1', 'header2'],
      'exposed_headers'   => ['header3', 'header4'],
      'allow_credentials' => true,
      'preflight_max_age' => 100,
      'enable_logging'    => true
    }

    let :params do
      {
        :directory => directory,
        :config => config
      }
    end
  
    it do
      should contain_lightblue__service__cors__configure("#{directory}/lightblue-crud-cors.json") \
      .with(config) \
      .with_notify('Service[jbossas]') \
      .with_require("File[#{directory}]")
    end
  end

  context 'when config is defined but empty' do
    directory = 'testdir'
    config = {}

    let :params do
      {
        :directory => directory,
        :config => config
      }
    end
  
    it do
      should contain_lightblue__service__cors__configure("#{directory}/lightblue-crud-cors.json") \
      .with({
        'url_patterns'      => nil,
        'allowed_origins'   => nil,
        'allowed_methods'   => nil,
        'allowed_headers'   => nil,
        'exposed_headers'   => nil,
        'allow_credentials' => nil,
        'preflight_max_age' => nil,
        'enable_logging'    => nil
      }) \
      .with_notify('Service[jbossas]') \
      .with_require("File[#{directory}]")
    end
  end

  context 'when config is undefined' do
    directory = 'testdir'

    let :params do
      {
        :directory => directory
      }
    end

    it do
      should_not contain_lightblue__service__cors__configure("#{directory}/lightblue-crud-cors.json")
    end
  end
end
