require 'spec_helper'

describe Atum::Generation::ErbContext do
  let(:ctx) { described_class.new }
  describe '#commentify' do
    let(:tabs) { 0 }
    subject(:result) { ctx.commentify(comment, tabs) }

    context 'when the comment is more than 78 characters' do
      let(:comment) { (['abc '] * 20).join }
      it 'should wrap by word' do
        firstline  = '# ' + (['abc '] * 19).join.strip
        secondline = '# abc'
        expect(result).to eq(firstline + "\n" + secondline)
      end
    end
  end
end
