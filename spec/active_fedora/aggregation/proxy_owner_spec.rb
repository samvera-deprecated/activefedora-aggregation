require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::ProxyOwner do
  before do
    class ExampleAggregation < ActiveFedora::Base
      aggregates :members
    end
  end
  after do
    Object.send(:remove_const, :ExampleAggregation)
  end

  describe "#delete_proxy!" do
    context "if head is equal to the proxy" do
      it "should set head to proxy's next" do
        next_proxy = build_proxy
        proxy = build_proxy(next_proxy: next_proxy)
        aggregation = build_aggregation(head: proxy)
        decorated_owner = described_class.new(aggregation)

        decorated_owner.delete_proxy!(proxy)

        expect(aggregation).to have_received(:head=).with(next_proxy)
      end
    end
    context "if tail is equal to the proxy" do
      it "should set tail to proxy's previous" do
        prev_proxy = build_proxy
        proxy = build_proxy(prev_proxy: prev_proxy)
        aggregation = build_aggregation(tail: proxy)
        decorated_owner = described_class.new(aggregation)

        decorated_owner.delete_proxy!(proxy)

        expect(aggregation).to have_received(:tail=).with(prev_proxy)
      end
    end
    context "if it's changed" do
      it "should save" do
        aggregation = build_aggregation(changed: true)
        decorated_owner = described_class.new(aggregation)

        decorated_owner.delete_proxy!(build_proxy)

        expect(aggregation).to have_received(:save!)
      end
    end

    def build_proxy(next_proxy:nil, prev_proxy:nil)
      proxy = object_double(ActiveFedora::Aggregation::Proxy.new)
      allow(proxy).to receive(:next).and_return(next_proxy)
      allow(proxy).to receive(:prev).and_return(prev_proxy)
      allow(proxy).to receive(:reload)
      proxy
    end

    def build_aggregation(head: nil, tail: nil, changed: false)
      aggregation = object_double(ExampleAggregation.new)
      allow(aggregation).to receive(:head=)
      allow(aggregation).to receive(:tail=)
      allow(aggregation).to receive(:head).and_return(head)
      allow(aggregation).to receive(:tail).and_return(tail)
      allow(aggregation).to receive(:changed?).and_return(changed)
      allow(aggregation).to receive(:save!)
      aggregation
    end
  end
end
