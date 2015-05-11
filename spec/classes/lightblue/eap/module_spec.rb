require 'spec_helper'

describe 'lightblue::eap::module' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  let :facts do
    {
      :architecture => 'x86_64'
    }
  end

  module_dir = "/usr/share/jbossas/modules/com/redhat/lightblue/main"

  context 'defaults' do
    it do
      should contain_file("#{module_dir}/lightblue-metadata.json")
      should contain_file("#{module_dir}/lightblue-crud.json")
      should contain_file("#{module_dir}/datasources.json")
      should contain_file("#{module_dir}/module.xml")
      should contain_file("#{module_dir}/config.properties")
      should contain_lightblue__service__cors__configure("#{module_dir}/lightblue-crud-cors.json") \
          .with({
            'url_patterns'      => ['/data/*'],
            'allowed_origins'   => ['origin1', 'origin2'],
            'allowed_methods'   => ['GET', 'POST'],
            'allowed_headers'   => ['header1', 'header2'],
            'exposed_headers'   => ['header3', 'header4'],
            'allow_credentials' => true,
            'preflight_max_age' => 100,
            'enable_logging'    => true
          }) \
          .with_require("File[#{module_dir}]")
      should contain_lightblue__service__cors__configure("#{module_dir}/lightblue-metadata-cors.json") \
          .with({
            'url_patterns'      => ['/metadata/*'],
            'allowed_origins'   => ['origin3', 'origin4'],
            'allowed_methods'   => ['PUT', 'DELETE'],
            'allowed_headers'   => ['header5', 'header6'],
            'exposed_headers'   => ['header7', 'header8'],
            'allow_credentials' => false,
            'preflight_max_age' => 1000,
            'enable_logging'    => false
          }) \
          .with_require("File[#{module_dir}]")
    end
  end

  context 'with undefined cors configs' do
    let :params do
      {
        # This won't work in puppet4 once undef != ''
        # https://tickets.puppetlabs.com/browse/PUP-1037
        # Setting these explicitly to undef would be better, but then rspec-puppet would use the hieradata
        # instead. Currently, rspec-puppet does not allow you to override hieradata in a spec.
        :data_cors_config => '',
        :metadata_cors_config => ''
      }
    end

    it do
      should_not contain_lightblue__service__cors__configure("#{module_dir}/lightblue-crud-cors.json")
      should_not contain_lightblue__service__cors__configure("#{module_dir}/lightblue-metadata-cors.json")
    end
  end

end
