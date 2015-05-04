require 'spec_helper'

describe ActiveFedora::Aggregation::ProxyContainer do
  let(:target1) { ActiveFedora::Base.create }
  let(:target2) { ActiveFedora::Base.create }
  let(:aggregator) { described_class.create }
  let(:parent) { Image.create }

  before do
    class GenericFile < ActiveFedora::Base
      contains :original
    end

    class Image < ActiveFedora::Base
      aggregates :generic_files
    end

    aggregator.parent = parent
  end

  after do
    Object.send(:remove_const, :Image)
    Object.send(:remove_const, :GenericFile)
  end

  describe "#target=" do
    before do
      aggregator.target= [target1, target2]
    end
    subject { aggregator.to_a }
    it { is_expected.to eq [target1, target2] }
  end

  describe "#<<" do
    context "the first one" do
      before do
        aggregator << target1
      end

      it "should set head and tail" do
        expect(aggregator.parent.head.target).to eq target1
        expect(aggregator.parent.head).to eq aggregator.parent.tail
      end
    end

    context "the second one" do
      before do
        aggregator << target1
        aggregator << target2
      end

      it "should set head and tail" do
        expect(aggregator.parent.head.target).to eq target1
        expect(aggregator.parent.tail.target).to eq target2
      end

      it "should establish next on the proxy" do
        expect(aggregator.parent.head.next).to eq aggregator.parent.tail
      end
    end
  end

  describe "readers" do
    before do
      aggregator << target1
      aggregator << target2
    end

    describe "#target_ids" do
      subject { aggregator.target_ids }
      it { is_expected.to eq [target1.id, target2.id] }
    end
  end
end
