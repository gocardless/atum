require 'spec_helper'

describe Atum do
  describe '.ruby_name' do
    it 'snake cases CapitalizedNames' do
      expect(Atum.ruby_name('CapitalizedName')).to eq('capitalizedname')
    end

    it 'snake cases dashed-names' do
      expect(Atum.ruby_name('dashed-name')).to eq('dashed_name')
    end

    it 'snake cases spaced names' do
      expect(Atum.ruby_name('spaced name')).to eq('spaced_name')
    end
  end

  describe '.pretty_name' do
    it 'lowercases capitals' do
      expect(Atum.pretty_name('CapitalizedName')).to eq('capitalizedname')
    end

    it 'dashes underscores and spaces' do
      expect(Atum.pretty_name('snake_case')).to eq('snake-case')
      expect(Atum.pretty_name('spaced words')).to eq('spaced-words')
    end
  end
end
