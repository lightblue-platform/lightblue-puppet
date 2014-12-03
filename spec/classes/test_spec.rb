require 'spec_helper'

describe 'lightblue::application::metadatamgmt' do
  it do
    should contain_package('lightblue-metadata-mgmt')
  end
end