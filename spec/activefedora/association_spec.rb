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
  let(:generic_file3) { GenericFile.create }

  context "with a defined class" do
    before do
      class Image < ActiveFedora::Base
        aggregates :generic_files
      end
    end

    after do
      Object.send(:remove_const, :Image)
    end

    let(:image) { Image.create }
    let(:image2) { Image.create }

    before do
      image.generic_files = [generic_file2, generic_file1]
      image.save
      image2.save
    end

    let(:reloaded) { Image.find(image.id) } # because reload doesn't clear this association

    describe "the association" do
      subject { reloaded.generic_files }
      it { is_expected.to eq [generic_file2, generic_file1] }

      it "should return an updated array of generic_files" do
        current_generic_files = image.generic_files.container.to_a
        new_generic_files = current_generic_files + [generic_file3]
        image.generic_files = new_generic_files
        expect(image.generic_files).to eq [generic_file2, generic_file1, generic_file3]
      end

      it "should return an updated array of generic_files when generic_files is empty" do
        current_generic_files = image2.generic_files.container.to_a
        new_generic_files = current_generic_files + [generic_file3]
        image.generic_files = new_generic_files
        binding.pry
        expect(image2.generic_files).to eq [generic_file3]
      end

      it "has a first element" do
        expect(subject.first).to eq generic_file2
      end

      it "uses the default predicate" do
        expect(reloaded.resource.query(predicate: ::RDF::Vocab::ORE.aggregates).count).to eq 2
      end
      it "associates directly to aggregated resource" do
        expect(reloaded.resource.query(predicate: ::RDF::Vocab::ORE.aggregates).to_a.first.object).to eq generic_file2.resource.rdf_subject
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

  context "without a defined class or class name (non-activefedora class)" do
    before do
      class Image < ActiveFedora::Base
        aggregates :files # This resolves to `class_name: ::File'
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

  context "without a defined class or class name (non-existing class)" do
    before do
      class Image < ActiveFedora::Base
        aggregates :foos # no real class
      end
    end

    after do
      Object.send(:remove_const, :Image)
    end

    let(:image) { Image.create }

    before do
      image.foos = [generic_file2, generic_file1]
      image.save
    end

    let(:reloaded) { Image.find(image.id) } # because reload doesn't clear this association

    describe "the association" do
      subject { reloaded.foos }
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
      subject { reloaded.generic_files }
      it { is_expected.to eq [generic_file2, generic_file1] }
    end
  end
end
