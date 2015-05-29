require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::DecoratorList do
  subject { described_class.new(decorator_1, decorator_2) }
  let(:decorator_1) { build_decorator }
  let(:decorator_2) { build_decorator }

  describe "#new" do
    it "should chain decorations" do
      asset = double("asset")
      decorated = double("decorated_asset")
      allow(decorator_1).to receive(:new).and_return(decorated)

      subject.new(asset)

      expect(decorator_1).to have_received(:new).with(asset)
      expect(decorator_2).to have_received(:new).with(decorated)
    end
  end

  def build_decorator
    d = double("decorator")
    allow(d).to receive(:new)
    d
  end
end
