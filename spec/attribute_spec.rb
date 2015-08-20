require 'spec_helper'

describe JSON2Ruby::Attribute do
  describe '#initialize' do
    it 'should set up correct attrs' do
      x = JSON2Ruby::Attribute.new('hello','world')
      expect(x.name).to eq("hello")
      expect(x.ruby_type).to eq("world")
    end

    it 'should have correct defaults' do
      x = JSON2Ruby::Attribute.new('hello')
      expect(x.name).to eq("hello")
      expect(x.ruby_type).to eq("_unknown")
    end
  end

  describe '#short_name' do
    it 'should have the correct short name' do
      expect(JSON2Ruby::Attribute.short_name).to eq('Attribute')
    end
  end

  describe '#attr_hash' do
    it 'should return correct hash' do
      x = JSON2Ruby::Attribute.new('hello','world')
      expect(x.attr_hash).to eq("6de41d334b7ce946682da48776a10bb9")
      x = JSON2Ruby::Attribute.new('foo','bar')
      expect(x.attr_hash).to eq("4e99e8c12de7e01535248d2bac85e732")
      x = JSON2Ruby::Attribute.new('hello','bar')
      expect(x.attr_hash).to eq("4b8ef9a9e864fb4035c8e45d41b085f7")
      x = JSON2Ruby::Attribute.new('foo','world')
      expect(x.attr_hash).to eq("b4738da083596d81a33ec6aabba9460b")
    end
  end

  describe '#==' do
    it 'should return false if class mismatch' do
      x = JSON2Ruby::Attribute.new('hello','world')

      expect(x=={}).to be(false)
      expect(x==[]).to be(false)
      expect(x==1).to be(false)
      expect(x=="hello").to be(false)
      expect(x==nil).to be(false)
    end

    it 'should return true if and only if attr_hash matches' do
      x = JSON2Ruby::Attribute.new('hello','world')
      y = JSON2Ruby::Attribute.new('foo','bar')
      z = JSON2Ruby::Attribute.new('hello','world')

      expect(x==x).to be(true)
      expect(x==y).to be(false)
      expect(x==z).to be(true)
    end
  end
end