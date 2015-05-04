require 'spec_helper'

describe ActiveFedora::Aggregation::Association do
  before do
    class GenericFile < ActiveFedora::Base
      contains :original
    end
  end

  after do
    Object.send(:remove_const, :GenericFile)
  end

  let(:generic_file1) { GenericFile.create }
  let(:generic_file2) { GenericFile.create }


  context "without a class name" do
    before do
      class Image < ActiveFedora::Base
        aggregates :generic_files
      end
    end

    after do
      Object.send(:remove_const, :Image)
    end

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

      it "uses the default predicate" do
        expect(reloaded.resource.query(predicate: ::RDF::Vocab::ORE.aggregates).count).to eq 2
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

  context "with a class name" do
    before do
      class Image < ActiveFedora::Base
        aggregates :files, class_name: 'GenericFile'
      end
    end

    after do
      Object.send(:remove_const, :Image)
    end

    let(:image) { Image.create }

    before do
      image.files = [generic_file2, generic_file1]
      image.save
    end

    let(:reloaded) { Image.find(image.id) } # because reload doesn't clear this association

    describe "the association" do
      subject { reloaded.files }
      it { is_expected.to eq [generic_file2, generic_file1] }
    end
  end

  context "with a predicate" do
    let(:predicate) { ::RDF::URI.new('http://fedora.info/ns/pcdm#hasMembers') }

    before do
      class Image < ActiveFedora::Base
        aggregates :generic_files, predicate: ::RDF::URI.new('http://fedora.info/ns/pcdm#hasMembers')
      end
    end

    after do
      Object.send(:remove_const, :Image)
    end

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

      it "uses the specified predicate" do
        query_result = reloaded.resource.query(predicate: predicate)
        expect(query_result.count).to eq 2
      end
    end
  end
end
