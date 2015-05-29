require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::DecoratingRepository do
  subject { described_class.new(decorator, base_repository) }
  # Responds to new and returns a decorated asset
  let(:decorator) { double("decorator") }
  # Responds to #new and #find and returns an asset
  let(:base_repository) { double("repository") }

  describe "#new" do
    it "should return a decorated asset from base_repository" do
      asset = double("asset")
      decorated_asset = double("decorated_asset")
      allow(base_repository).to receive(:new).and_return(asset)
      allow(decorator).to receive(:new).with(asset).and_return(decorated_asset)

      expect(subject.new).to eq decorated_asset
    end
    it "should pass on arguments to base_repository" do
      allow(base_repository).to receive(:new)
      allow(decorator).to receive(:new)

      subject.new(:test => 1)
      expect(base_repository).to have_received(:new).with(:test => 1)
    end
  end
  describe "#find" do
    it "should return a decorated asset from base_repository" do
      id = double("id")
      asset = double("asset")
      decorated_asset = double("decorated_asset")
      allow(base_repository).to receive(:find).with(id).and_return(asset)
      allow(decorator).to receive(:new).with(asset).and_return(decorated_asset)

      expect(subject.find(id)).to eq decorated_asset
    end
  end
end
