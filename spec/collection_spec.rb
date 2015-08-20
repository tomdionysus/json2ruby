require 'spec_helper'

describe JSON2Ruby::Collection do
  describe '#initialize' do
    it 'should set up correct attrs' do
      x = JSON2Ruby::Collection.new('hello',{ :test => 1, :test2 => 2})
      expect(x.name).to eq("hello")
      expect(x.ruby_types).to eq({ :test => 1, :test2 => 2})
    end

    it 'should have the correct defaults' do
      x = JSON2Ruby::Collection.new('hello')
      expect(x.name).to eq("hello")
      expect(x.ruby_types).to eq({})
    end
  end

  describe '#short_name' do
    it 'should have the correct short name' do
      expect(JSON2Ruby::Collection.short_name).to eq('Collection')
    end
  end

  describe '#attr_hash' do
    it 'should return correct hash' do
      types = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
      }
      x = JSON2Ruby::Collection.new('hello',types)
      expect(x.attr_hash).to eq("b99a7214ee0aa2cb312890eb5374aa20")

      x.ruby_types = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
      }
      expect(x.attr_hash).to eq("5392fad6bee373074dbd3edfae6506f2")
    end
  end

  describe '#==' do
    it 'should return false if class mismatch' do
      x = JSON2Ruby::Collection.new('hello','world')

      expect(x=={}).to be(false)
      expect(x==[]).to be(false)
      expect(x==1).to be(false)
      expect(x=="hello").to be(false)
      expect(x==nil).to be(false)
    end

    it 'should return true if and only if attr_hash matches' do
      types = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
      }
      x = JSON2Ruby::Collection.new('hello',types)

      types = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
      }
      y = JSON2Ruby::Collection.new('hello',types)

      types = {
        JSON2Ruby::RUBYSTRING.attr_hash => JSON2Ruby::RUBYSTRING,
        JSON2Ruby::RUBYINTEGER.attr_hash => JSON2Ruby::RUBYINTEGER,
      }
      z = JSON2Ruby::Collection.new('hello',types)

      expect(x==x).to be(true)
      expect(x==y).to be(false)
      expect(x==z).to be(true)
    end
  end

  describe '#comment' do
    it 'should return correct values' do
      x = JSON2Ruby::Collection.new('hello')
      expect(x.comment).to eq("hello[]")

      x.original_name = "test!"
      expect(x.comment).to eq("hello[] (test!)")
    end
  end
end