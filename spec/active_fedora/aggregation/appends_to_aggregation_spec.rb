require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::AppendsToAggregation do
  subject { described_class.new(proxy, aggregation) }
  let(:proxy) { object_double(ActiveFedora::Aggregation::Proxy.new) }
  let(:aggregation) { object_double(ActiveFedora::Base) }

  describe "#is_a?" do
    # Necessary for association setting.
    it "should return true for the aggregation class" do
      expect(subject.is_a?(aggregation.class)).to eq true
    end
  end

  describe "#save" do
    context "when the proxy fails to save" do
      it "should not add the link" do
        allow(proxy).to receive(:save).and_return(false)
        allow(ActiveFedora::Aggregation::LinkInserter).to receive(:new)

        subject.save

        expect(ActiveFedora::Aggregation::LinkInserter).not_to have_received(:new)
      end
    end
    context "when the proxy saves" do
      it "should add the link" do
        # A lot of stubbing necessary - refactoring probably necessary.
        allow(proxy).to receive(:save).and_return(true)
        link_inserter = instance_double(ActiveFedora::Aggregation::LinkInserter)
        allow(ActiveFedora::Aggregation::LinkInserter).to receive(:new).and_return(link_inserter)
        allow(link_inserter).to receive(:call)

        subject.save

        expect(ActiveFedora::Aggregation::LinkInserter).to have_received(:new).with(aggregation, proxy)
        expect(link_inserter).to have_received(:call)
      end
    end
  end
end
