require 'spec_helper'

describe Atum::Core::ApiError do
  let(:message) { 'Foo failed' }
  let(:url) { 'http://example.com/how-to-fix' }

  subject { described_class.new(error).message }

  context 'without a documentation url' do
    let(:error) { { 'message' => message } }
    it { is_expected.to eq(message) }
  end

  context 'with a documentation url' do
    let(:error) { { 'message' => message, 'documentation_url' => url } }
    it { is_expected.to include(message) }
    it { is_expected.to include(url) }
  end
end
