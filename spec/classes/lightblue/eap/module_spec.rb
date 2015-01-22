require 'spec_helper'

describe 'lightblue::eap::module' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  context 'defaults' do

    describe 'defaults' do
      let :params do
        {
        }
      end

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
      end
    end
  end

end
