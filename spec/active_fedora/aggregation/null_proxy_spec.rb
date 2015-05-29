require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::NullProxy do
  subject { described_class.instance }
  describe "#prev" do
    it "should return itself" do
      expect(subject.prev).to eq subject
    end
  end

  describe "#next" do
    it "should return itself" do
      expect(subject.next).to eq subject
    end
  end

  describe "#next=" do
    it "shouldn't work" do
      subject.next = "bla"

      expect(subject.next).to eq subject
    end
  end

  describe "#prev=" do
    it "shouldn't work" do
      subject.prev = "bla"

      expect(subject.prev).to eq subject
    end
  end

  describe "#reload" do
    it "should return itself" do
      expect(subject.reload).to eq subject
    end
  end

  describe "#changed?" do
    it "should be false" do
      expect(subject).not_to be_changed
    end
    it "should be false when prev is set" do
      subject.prev = "bla"
      expect(subject).not_to be_changed
    end
  end
end
