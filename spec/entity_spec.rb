require 'spec_helper'

describe JSON2Ruby::Entity do
  describe '#initialize' do
    it 'should set up correct attrs' do
      x = JSON2Ruby::Entity.new('hello',{ :test => 1, :test2 => 2})
      expect(x.name).to eq("hello")
      expect(x.attributes).to eq({ :test => 1, :test2 => 2})
    end

    it 'should have the correct defaults' do
      x = JSON2Ruby::Entity.new('hello')
      expect(x.name).to eq("hello")
      expect(x.attributes).to eq({})
    end
  end

  describe '#short_name' do
    it 'should have the correct short name' do
      expect(JSON2Ruby::Entity.short_name).to eq('Entity')
    end
  end

  describe '#self.parse_from' do
    it 'should parse' do
      obj = {
        "one" => "1",
        "two" => 2,
        "three" => 3.14,
        "four" => true,
        "five" => {
          "5.1"=>5.1
        },
        "six" => [ 1,2,3 ]
      }

      ent = JSON2Ruby::Entity.parse_from("Test",obj)

      expect(ent).to be_a(JSON2Ruby::Entity)
      expect(ent.name).to eq("Test")
      expect(ent.attributes.length).to eq(6)
      expect(ent.attr_hash).to eq("e17024aea3f6f3623dda7170697a72dd")
    end

    it 'should use numeric instead of int/float when told to' do
      obj = {
        "one" => "1",
        "two" => 2,
        "three" => 3.14,
        "four" => true,
        "five" => {
          "5.1"=>5.1
        },
        "six" => [ 1,2,3 ]
      }

      ent = JSON2Ruby::Entity.parse_from("Test",obj, {:forcenumeric=>true})

      expect(ent).to be_a(JSON2Ruby::Entity)
      expect(ent.name).to eq("Test")
      expect(ent.attributes.length).to eq(6)
      expect(ent.attr_hash).to eq("592884f7d98c4a31b7d641b10636d546")
    end
  end

  describe '#attr_hash' do
    it 'should return correct hash' do
      attrs = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
      }
      x = JSON2Ruby::Entity.new('hello',attrs)
      expect(x.attr_hash).to eq("91c9d28d138816b43934d63c0a4b443f")

      x.attributes = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
      }
      expect(x.attr_hash).to eq("1bf08c8584361b8b12e1278e0e095340")
    end
  end

  describe '#==' do
    it 'should return false if class mismatch' do
      x = JSON2Ruby::Entity.new('hello','world')

      expect(x=={}).to be(false)
      expect(x==[]).to be(false)
      expect(x==1).to be(false)
      expect(x=="hello").to be(false)
      expect(x==nil).to be(false)
    end

    it 'should return true if and only if attr_hash matches' do
      attrs = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
      }
      x = JSON2Ruby::Entity.new('hello',attrs)

      attrs = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
      }
      y = JSON2Ruby::Entity.new('hello',attrs)

      attrs = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
      }
      z = JSON2Ruby::Entity.new('hello',attrs)


      expect(x==x).to be(true)
      expect(x==y).to be(false)
      expect(x==z).to be(true)
    end
  end

  describe '#self.get_next_unknown' do

    it 'should return different results after each call' do

      x = JSON2Ruby::Entity.get_next_unknown
      y = JSON2Ruby::Entity.get_next_unknown
      z = JSON2Ruby::Entity.get_next_unknown

      expect(x==y).to be(false)
      expect(y==z).to be(false)
      expect(z==x).to be(false)
    end
  end

  describe '#self.reset_parse' do
    it 'should be standard after reset' do
      JSON2Ruby::Entity.class_variable_set('@@objs',[1,2,3])

      JSON2Ruby::Entity.reset_parse

      expect(JSON2Ruby::Entity.entities).to eq({
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
        JSON2Ruby::RUBYFLOAT.attr_hash => JSON2Ruby::RUBYFLOAT,
        JSON2Ruby::RUBYBOOLEAN.attr_hash => JSON2Ruby::RUBYBOOLEAN,
        JSON2Ruby::RUBYNUMERIC.attr_hash => JSON2Ruby::RUBYNUMERIC,
      })
    end
  end

  describe '#self.entities' do
    it 'should return @@objs' do
      JSON2Ruby::Entity.class_variable_set('@@objs',[1,2,3])
      expect(JSON2Ruby::Entity.entities).to eq([1,2,3])
    end

    it 'should be standard after reset' do
      JSON2Ruby::Entity.class_variable_set('@@objs',[1,2,3])

      JSON2Ruby::Entity.reset_parse

      expect(JSON2Ruby::Entity.entities).to eq({
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
        JSON2Ruby::RUBYFLOAT.attr_hash => JSON2Ruby::RUBYFLOAT,
        JSON2Ruby::RUBYBOOLEAN.attr_hash => JSON2Ruby::RUBYBOOLEAN,
        JSON2Ruby::RUBYNUMERIC.attr_hash => JSON2Ruby::RUBYNUMERIC,
      })
    end
  end

  describe '#comment' do
    it 'should return correct values' do
      x = JSON2Ruby::Entity.new('hello')
      expect(x.comment).to eq("hello")

      x.original_name = "test!"
      expect(x.comment).to eq("hello (test!)")
    end
  end
end