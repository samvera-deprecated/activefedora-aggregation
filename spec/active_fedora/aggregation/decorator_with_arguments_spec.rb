require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::DecoratorWithArguments do
  subject { described_class.new(decorator, argument_1, argument_2) }
  let(:decorator) { double("decorator") }
  let(:argument_1) { double("argument1") }
  let(:argument_2) { double("argument2") }

  describe "#new" do
    it "should call #new on decorator with arguments" do
      asset = double("asset")
      decorated = double("decorated_asset")
      allow(decorator).to receive(:new).and_return(decorated)

      result = subject.new(asset)

      expect(decorator).to have_received(:new).with(asset, argument_1, argument_2)
      expect(result).to eq decorated
    end
  end
end
