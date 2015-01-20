require 'spec_helper'

describe 'lightblue::eap::module::metadata' do

  let(:hiera_config){ 'spec/fixtures/hiera/hiera.yaml' }

  context 'lightblue-metadata.json' do

    describe 'defaults' do
      let :params do
        {
          :directory => '/tmp'
        }
      end

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

    describe 'roleMap single values' do
      let :params do
        {
          :directory => '/tmp',
          :metadata_roles => {
              'metadata.find.dependencies' => 'find.dependencies',
              'metadata.find.roles' => 'find.roles',
              'metadata.find.entityNames' => 'find.entityNames',
              'metadata.find.entityVersions' => 'find.entityVersions',
              'metadata.find.entityMetadata' => 'find.entityMetadata',
              'metadata.insert' => 'insert',
              'metadata.insert.schema' => 'insert.schema',
              'metadata.update.entityInfo' => 'update.entityInfo',
              'metadata.update.schemaStatus' => 'update.schemaStatus',
              'metadata.update.defaultVersion' => 'update.defaultVersion',
              'metadata.delete.entity' => 'delete.entity'
          }
        }
      end

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
          .with_content(/"roleMap":/) \
          .without_content(/"backend_parsers":/) \
          .without_content(/"property_parsers":/) \
          .with_content(/"dataSource": "metadata",/) \
          .with_content(/"collection": "metadata"/) \
          .with_content(/"metadata.find.dependencies": \["find.dependencies"\]/) \
          .with_content(/"metadata.find.roles": \["find.roles"\]/) \
          .with_content(/"metadata.find.entityNames": \["find.entityNames"\]/) \
          .with_content(/"metadata.find.entityVersions": \["find.entityVersions"\]/) \
          .with_content(/"metadata.find.entityMetadata": \["find.entityMetadata"\]/) \
          .with_content(/"metadata.insert": \["insert"\]/) \
          .with_content(/"metadata.insert.schema": \["insert.schema"\]/) \
          .with_content(/"metadata.update.entityInfo": \["update.entityInfo"\]/) \
          .with_content(/"metadata.update.schemaStatus": \["update.schemaStatus"\]/) \
          .with_content(/"metadata.update.defaultVersion": \["update.defaultVersion"\]/) \
          .with_content(/"metadata.delete.entity": \["delete.entity"\]/)
      end
    end

    describe 'roleMap multiple values' do
      let :params do
        {
          :directory => '/tmp',
          :metadata_roles => {
              'metadata.find.dependencies' => ['find.dependencies','find.dependencies2'],
              'metadata.find.roles' => ['find.roles','find.roles2'],
              'metadata.find.entityNames' => ['find.entityNames','find.entityNames2'],
              'metadata.find.entityVersions' => ['find.entityVersions','find.entityVersions2'],
              'metadata.find.entityMetadata' => ['find.entityMetadata','find.entityMetadata2'],
              'metadata.insert' => ['insert','insert2'],
              'metadata.insert.schema' => ['insert.schema','insert.schema2'],
              'metadata.update.entityInfo' => ['update.entityInfo','update.entityInfo2'],
              'metadata.update.schemaStatus' => ['update.schemaStatus','update.schemaStatus2'],
              'metadata.update.defaultVersion' => ['update.defaultVersion','update.defaultVersion2'],
              'metadata.delete.entity' => ['delete.entity','delete.entity2']
          }
        }
      end

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
          .with_content(/"roleMap":/) \
          .without_content(/"backend_parsers":/) \
          .without_content(/"property_parsers":/) \
          .with_content(/"dataSource": "metadata",/) \
          .with_content(/"collection": "metadata"/) \
          .with_content(/"metadata.find.dependencies": \["find.dependencies",[ ]*"find.dependencies2"\]/) \
          .with_content(/"metadata.find.roles": \["find.roles",[ ]*"find.roles2"\]"/) \
          .with_content(/"metadata.find.entityNames": \["find.entityNames",[ ]*"find.entityNames2"\]"/) \
          .with_content(/"metadata.find.entityVersions": \["find.entityVersions",[ ]*"find.entityVersions2"\]"/) \
          .with_content(/"metadata.find.entityMetadata": \["find.entityMetadata",[ ]*"find.entityMetadata2"\]"/) \
          .with_content(/"metadata.insert": \["insert",[ ]*"insert2"\]"/) \
          .with_content(/"metadata.insert.schema": \["insert.schema",[ ]*"insert.schema2"\]"/) \
          .with_content(/"metadata.update.entityInfo": \["update.entityInfo",[ ]*"update.entityInfo2"\]"/) \
          .with_content(/"metadata.update.schemaStatus": \["update.schemaStatus",[ ]*"update.schemaStatus2"\]"/) \
          .with_content(/"metadata.update.defaultVersion": \["update.defaultVersion",[ ]*"update.defaultVersion2"\]"/) \
          .with_content(/"metadata.delete.entity": \["delete.entity",[ ]*"delete.entity2"\]"/)
      end
    end
  end

end
