require 'spec_helper'

describe ActiveFedora::Aggregation::Association do
  before do
    class GenericFile < ActiveFedora::Base
      contains :original
    end

    class Image < ActiveFedora::Base
      aggregates :generic_files
    end
  end

  after do
    Object.send(:remove_const, :Image)
  end

  let(:generic_file1) { GenericFile.create }
  let(:generic_file2) { GenericFile.create }

  let(:image) { Image.create }

  before do
    image.generic_files = [generic_file2, generic_file1]
    image.save
  end

  let(:reloaded) { Image.find(image.id) } # because reload doesn't clear this association

  describe "the association" do
    subject { reloaded.generic_files }
    it { is_expected.to eq [generic_file2, generic_file1] }

    it "has a first element" do
      expect(subject.first).to eq generic_file2
    end
  end

  describe "#head" do
    it "returns the first proxy" do
      expect(reloaded.head).to be_kind_of ActiveFedora::Aggregation::Proxy
    end
  end
  describe "#head_id" do
    it "returns the first proxy" do
      expect(reloaded.head_id).to be_kind_of String
    end
  end
end
