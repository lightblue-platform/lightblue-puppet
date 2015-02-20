require 'spec_helper'

describe 'lightblue::application::datamgmt' do
  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  let :facts do
    {
      :architecture => 'x86_64',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0'
    }
  end

  context 'with default params' do
    it do
      should contain_package('lightblue-data-mgmt') \
        .with_ensure('latest') \
        .with_require(['Class[Lightblue::Yumrepo::Lightblue]', 'Class[Lightblue::Eap]'])
    end

    it do
      should contain_class('Lightblue::Eap')
    end

    it do
      should contain_class('Lightblue::Yumrepo::Lightblue')
    end
  end

  context 'when using saml auth' do
    app_uri = 'http://datamgmt.lightblue.mycompany.com'

    let :params do
      {
        :package_name => 'lightblue-data-mgmt-saml-auth',
        :app_uri      => app_uri
      }
    end

    it do
      should contain_package('lightblue-data-mgmt-saml-auth') \
        .with_ensure('latest') \
        .with_require(['Class[Lightblue::Yumrepo::Lightblue]', 'Class[Lightblue::Eap]'])
    end

    it do
      should contain_lightblue__jcliff__config('data-mgmt-system-properties.conf') \
        .with_content("{ 'system-property' => { 'DataMgmtURL' => '#{app_uri}' } }")
    end
  end
end