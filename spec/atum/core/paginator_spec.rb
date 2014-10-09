require 'spec_helper'

describe Atum::Core::Paginator do
  let(:items) do
    (1..100).map do |i|
      { name: "item_#{i}" }
    end
  end
  let(:initial_limit) { 50 }
  let(:limit_increment) { 50 }
  let(:request) { double(make_request: response) }
  let(:response) { double(body: anything) }
  let(:options) { {} }
  let(:paginator) { described_class.new(request, response, options) }
  let(:after) { double }

  describe '#enumerator' do
    subject(:enumerator) { paginator.enumerator }
    before do
      allow(request).to receive(:unenvelope)
        .and_return(items[0...initial_limit],
                    items[initial_limit...initial_limit * 2])
      allow(response).to receive(:limit)
        .and_return(initial_limit, initial_limit,
                    initial_limit + limit_increment,
                    initial_limit + limit_increment)
      allow(response).to receive(:meta)
        .and_return('cursors' => { 'after' => after })
    end

    it { is_expected.to be_an(Enumerator) }

    context 'when the number of items required is < LIMIT_INCREMENT' do
      before { stub_const('Atum::Core::Paginator::LIMIT_INCREMENT', limit_increment) }

      it "doesn't fetch any more pages of data" do
        expect(request).to_not receive(:make_request)
        enumerator.take(limit_increment - 1).to_a
      end
    end

    context 'when the number of items required is = LIMIT_INCREMENT' do
      before { stub_const('Atum::Core::Paginator::LIMIT_INCREMENT', limit_increment) }

      it "doesn't fetch any more pages of data" do
        expect(request).to_not receive(:make_request)
        enumerator.take(limit_increment).to_a
      end
    end

    context 'when the number of items required is > LIMIT_INCREMENT' do
      before { stub_const('Atum::Core::Paginator::LIMIT_INCREMENT', limit_increment) }

      it 'fetches another page of data' do
        expect(request).to receive(:make_request).once
        enumerator.take(limit_increment + 1).to_a
      end

      it 'sends after as a query param' do
        expect(request).to receive(:make_request)
          .with(query: hash_including(after: after))
        enumerator.take(limit_increment + 1).to_a
      end

      it 'increases the requested limit on each successive fetch' do
        expect(request).to receive(:make_request)
          .with(query: hash_including(limit: initial_limit + limit_increment))
        enumerator.take(limit_increment + 1).to_a
      end
    end
  end
end
