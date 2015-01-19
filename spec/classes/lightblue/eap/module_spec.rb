require 'spec_helper'

describe 'lightblue::eap::module' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  context 'deploy lightblue-metadata.yaml' do

    describe 'without metadata_roles' do

      let :params do
        {
          :metadata_roles => undef
        }
      end

      it do
        should contain_file('/usr/share/jbossas/modules/com/redhat/lightblue/main/lightblue-metadata.json') \
          .with({
              'ensure'  => 'file',
              'owner'   => 'jboss',
              'group'   => 'jboss',
              'mode'    => '0644'
            }
          ) \
          .without_content(/roleMap/)
      end

    end

  end

end
