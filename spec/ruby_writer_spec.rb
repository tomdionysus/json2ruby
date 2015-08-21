require 'spec_helper'
require 'ostruct'

describe JSON2Ruby::RubyWriter do

  describe '#to_code' do
    it 'should return correct code for classes' do
      entity = OpenStruct.new({ 
        :name => "TestEntitiy",
      })

      options = {
        :require => [ 'recone', 'rectwo', 'recthree' ],
        :include => [ 'incone', 'inctwo', 'incthree' ],
        :extend => [ 'excone', 'exctwo', 'excthree' ],
        :superclass_name => 'Superclass',
        :modules => false,
      }

      expect(JSON2Ruby::RubyWriter).to receive(:attributes_to_ruby).with(entity, 2, options).and_return("")

      expect(JSON2Ruby::RubyWriter.to_code(entity,0,options)).to eq("require 'recone'\r\nrequire 'rectwo'\r\nrequire 'recthree'\r\n\r\nclass TestEntitiy < Superclass\r\n  extend excone\r\n  extend exctwo\r\n  extend excthree\r\n\r\n  include incone\r\n  include inctwo\r\n  include incthree\r\n\r\nend\r\n")
    end

    it 'should return correct code for modules' do
      entity = OpenStruct.new({ 
        :name => "TestEntitiy",
      })

      options = {
        :require => [ 'recone', 'rectwo', 'recthree' ],
        :include => [ 'incone', 'inctwo', 'incthree' ],
        :extend => [ 'excone', 'exctwo', 'excthree' ],
        :superclass_name => 'Superclass',
        :modules => true,
      }

      expect(JSON2Ruby::RubyWriter).to receive(:attributes_to_ruby).with(entity, 2, options).and_return("")

      expect(JSON2Ruby::RubyWriter.to_code(entity,0,options)).to eq("require 'recone'\r\nrequire 'rectwo'\r\nrequire 'recthree'\r\n\r\nmodule TestEntitiy < Superclass\r\n  extend excone\r\n  extend exctwo\r\n  extend excthree\r\n\r\n  include incone\r\n  include inctwo\r\n  include incthree\r\n\r\nend\r\n")
    end
  end

  describe '#attributes_to_ruby' do
    it 'should return correct code for simple attrs' do
      entity = OpenStruct.new({ 
        :name => "TestEntitiy",
        :attributes => {
          "test1" => OpenStruct.new({:comment => 'test1 comment'}),
          "test2" => OpenStruct.new({:comment => 'test2 comment'}),
        }
      })

      options = {
        :collectionmethod => 'collectionmethod',
        :attributemethod => 'attributemethod',
      }

      expect(JSON2Ruby::RubyWriter.attributes_to_ruby(entity,0,options)).to eq("attributemethod :test1 # test1 comment\r\nattributemethod :test2 # test2 comment\r\n")
    end

    it 'should return correct code for attrs that are primitives' do
      entity = OpenStruct.new({ 
        :name => "TestEntitiy",
        :attributes => {
          "test1" => JSON2Ruby::RUBYSTRING,
          "test2" => OpenStruct.new({:comment => 'test2 comment'}),
        }
      })

      options = {
        :collectionmethod => 'collectionmethod',
        :attributemethod => 'attributemethod',
      }

      expect(JSON2Ruby::RubyWriter.attributes_to_ruby(entity,0,options)).to eq("attributemethod :test1 # String\r\nattributemethod :test2 # test2 comment\r\n")
    end

    it 'should return correct code for collections' do
      entity = OpenStruct.new({ 
        :name => "TestEntitiy",
        :attributes => {
          "testCollection" => JSON2Ruby::Collection.new("testCol"),
          "test2" => OpenStruct.new({:comment => 'test2 comment'}),
        }
      })

      options = {
        :collectionmethod => 'collectionmethod',
        :attributemethod => 'attributemethod',
      }

      expect(JSON2Ruby::RubyWriter.attributes_to_ruby(entity,0,options)).to eq("collectionmethod :testCollection # testCol[]\r\nattributemethod :test2 # test2 comment\r\n")
    end

    it 'should return correct code for attrs and include type as second param' do
      entity = OpenStruct.new({ 
        :name => "TestEntitiy",
        :attributes => {
          "test1" => OpenStruct.new({:comment => 'test1 comment'}),
          "test2" => OpenStruct.new({:comment => 'test2 comment'}),
        }
      })

      options = {
        :collectionmethod => 'collectionmethod',
        :attributemethod => 'attributemethod',
        :includetypes => true,
      }

      expect(JSON2Ruby::RubyWriter.attributes_to_ruby(entity,0,options)).to eq("attributemethod :test1, '' # test1 comment\r\nattributemethod :test2, '' # test2 comment\r\n")
    end


  end

end