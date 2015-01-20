require 'spec_helper'

describe 'lightblue::eap::module::metadata' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  let :params do
    {
      :directory => '/tmp'
    }
  end

  context 'deploy lightblue-metadata.yaml' do

    describe 'with default parameters' do

      it do
        should contain_file("/tmp/lightblue-metadata.json") \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .with_content(/"documentation":/) \
          .with_content(/"type":/) \
          .without_content(/"hookConfigurationParsers":/) \
          .without_content(/"roleMap":/) \
          .without_content(/"backend_parsers":/) \
          .without_content(/"property_parsers":/) \
          .with_content(/"dataSource": "metadata",/) \
          .with_content(/"collection": "metadata"/)
      end

    end

  end

end
