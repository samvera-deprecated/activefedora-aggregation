require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::OrderedProxy do
  subject { described_class.new(proxy, aggregation) }
  let(:proxy) { object_double(ActiveFedora::Aggregation::Proxy.new) }
  let(:aggregation) { object_double(ActiveFedora::Aggregation::ProxyOwner.new(ActiveFedora::Base.new), :delete_proxy! => nil, :reload => nil) }

  describe "#is_a?" do
    # Necessary to set this as an association point
    it "should be true for the aggregation's class" do
      expect(subject.is_a?(aggregation.class)).to eq true
    end
  end

  describe "#delete" do
    it "should set next/prev" do
      # Yikes - Law of Demeter violation. Can we avoid it? Decorate proxy when
      # incoming? Add the delegation methods to our proxy object?
      next_proxy = build_proxy(name: "next")
      prev_proxy = build_proxy(name: "prev")
      stub_proxy(next_proxy: next_proxy, prev_proxy: prev_proxy)

      subject.delete

      expect(next_proxy).to have_received(:prev=).with(prev_proxy)
      expect(prev_proxy).to have_received(:next=).with(next_proxy)
    end
    it "should call delete_proxy!" do
      stub_proxy

      subject.delete

      expect(aggregation).to have_received(:delete_proxy!).with(subject)
    end
    it "should call delete on the source proxy" do
      stub_proxy

      subject.delete

      expect(proxy).to have_received(:delete)
    end
    it "should return the result of the owner's delete call" do
      stub_proxy
      delete_result = double("result")
      allow(proxy).to receive(:delete).and_return(delete_result)
      
      result = subject.delete

      expect(result).to eq delete_result
    end
    context "and the next node changed" do
      it "should save it" do
        next_proxy = build_proxy(name: "next", changed: true)
        prev_proxy = build_proxy(name: "prev", changed: false)
        stub_proxy(next_proxy: next_proxy)

        subject.delete

        expect(next_proxy).to have_received(:save!)
        expect(prev_proxy).not_to have_received(:save!)
      end
    end
    context "and the proxy delete fails" do
      it "should not delete the proxy" do
        stub_proxy
        allow(proxy).to receive(:delete).and_return(false)

        subject.delete

        expect(aggregation).not_to have_received(:delete_proxy!)
      end
    end
  end

  def stub_proxy(next_proxy: nil, prev_proxy: nil)
    allow(proxy).to receive(:next).and_return(next_proxy)
    allow(proxy).to receive(:prev).and_return(prev_proxy)
    allow(proxy).to receive(:delete).and_return(true)
  end

  def build_proxy(name:, changed: false)
    proxy = double(name)
    allow(proxy).to receive(:prev=)
    allow(proxy).to receive(:next=)
    allow(proxy).to receive(:changed?).and_return(changed)
    allow(proxy).to receive(:save!)
    allow(proxy).to receive(:reload)
    proxy
  end
end
