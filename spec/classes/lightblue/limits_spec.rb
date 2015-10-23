require 'spec_helper'

describe 'lightblue::limits' do

  context 'no limits' do
    it do
      should contain_file("/etc/security/limits.d/10-nproc.conf") \
        .with({
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644'
          }
        ) \
        .without_content("/^jboss.*$/")
    end
  end

  context 'soft nproc' do
    let :params do
      { 
        :soft_nproc => 1234
      }
    end

    it do
      should contain_file("/etc/security/limits.d/10-nproc.conf") \
        .with_content(/^jboss soft nproc 1234$/) \
        .without_content(/^jboss hard/) \
        .with({
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644'
          }
        )
    end
  end

  context 'hard nproc' do
    let :params do
      { 
        :hard_nproc => 9876
      }
    end

    it do
      should contain_file("/etc/security/limits.d/10-nproc.conf") \
        .without_content(/^jboss soft/) \
        .with_content(/^jboss hard nproc 9876$/) \
        .with({
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644'
          }
        )
    end
  end

  context 'soft and hard nproc' do
    let :params do
      {
        :soft_nproc => 1234,
        :hard_nproc => 9876
      }
    end

    it do
      should contain_file("/etc/security/limits.d/10-nproc.conf") \
        .with_content(/^jboss soft nproc 1234$/) \
        .with_content(/^jboss hard nproc 9876$/) \
        .with({
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644'
          }
        )
    end
  end
end
