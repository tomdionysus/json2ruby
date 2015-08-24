require 'spec_helper'

describe JSON2Ruby::Primitive do
  describe '#initialize' do
    it 'should set up correct attrs' do
      x = JSON2Ruby::Primitive.new('hello','world')
      expect(x.name).to eq("hello")
      expect(x.attr_hash).to eq("world")
    end
  end

  describe '#short_name' do
    it 'should have the correct short name' do
      expect(JSON2Ruby::Primitive.short_name).to eq('Primitive')
    end
  end

  describe '#attr_hash' do
    it 'should return hash' do
      x = JSON2Ruby::Primitive.new('hello','world')
      expect(x.attr_hash).to eq("world")
    end
  end

  describe '#comment' do
    it 'should return hash' do
      x = JSON2Ruby::Primitive.new('hello','world')
      expect(x.comment).to eq("hello")
    end
  end

  describe 'Standard Primitives' do
    it 'should have standard primitives correctly defined' do
      
      expect(JSON2Ruby::RUBYSTRING.name).to eq('String')
      expect(JSON2Ruby::RUBYSTRING.attr_hash).to eq('0123456789ABCDEF0123456789ABCDEF')

      expect(JSON2Ruby::RUBYINTEGER.name).to eq('Integer')
      expect(JSON2Ruby::RUBYINTEGER.attr_hash).to eq('0123456789ABCDEF0123456789ABCDE0')

      expect(JSON2Ruby::RUBYFLOAT.name).to eq('Float')
      expect(JSON2Ruby::RUBYFLOAT.attr_hash).to eq('0123456789ABCDEF0123456789ABCDE1')

      expect(JSON2Ruby::RUBYBOOLEAN.name).to eq('Boolean')
      expect(JSON2Ruby::RUBYBOOLEAN.attr_hash).to eq('0123456789ABCDEF0123456789ABCDE2')

      expect(JSON2Ruby::RUBYNUMERIC.name).to eq('Numeric')
      expect(JSON2Ruby::RUBYNUMERIC.attr_hash).to eq('0123456789ABCDEF0123456789ABCDE3')
    end
  end
end