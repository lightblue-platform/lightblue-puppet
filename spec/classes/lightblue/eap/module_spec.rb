require 'spec_helper'

describe 'lightblue::eap::module' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  let :facts do
    {
      :architecture => 'x86_64'
    }
  end

  context 'defaults' do
    it do
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-metadata.json")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-crud.json")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/datasources.json")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/module.xml")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/appconfig.properties")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-client.properties")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/config.properties")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/cacert.pem")
      should contain_file("/usr/share/jbossas/modules/com/redhat/lightblue/main/lb-metadata-mgmt.pkcs12")
      should contain_class("lightblue::eap::module::cors::data") \
          .with({
            "directory" => "/usr/share/jbossas/modules/com/redhat/lightblue/main",
            "config" => {
              'url_patterns'      => ['/data/*'],
              'allowed_origins'   => ['origin1', 'origin2'],
              'allowed_methods'   => ['GET', 'POST'],
              'allowed_headers'   => ['header1', 'header2'],
              'exposed_headers'   => ['header3', 'header4'],
              'allow_credentials' => true,
              'preflight_max_age' => 100,
              'enable_logging'    => true
            }
          })
      should contain_class("lightblue::eap::module::cors::metadata") \
          .with({
            "directory" => "/usr/share/jbossas/modules/com/redhat/lightblue/main",
            "config" => {
              'url_patterns'      => ['/metadata/*'],
              'allowed_origins'   => ['origin3', 'origin4'],
              'allowed_methods'   => ['PUT', 'DELETE'],
              'allowed_headers'   => ['header5', 'header6'],
              'exposed_headers'   => ['header7', 'header8'],
              'allow_credentials' => false,
              'preflight_max_age' => 1000,
              'enable_logging'    => false
            }
          })
    end
  end

end
