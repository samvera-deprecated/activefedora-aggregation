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

    let(:reloaded) { Image.find(image.id) } # because reload doesn't clear this association

    context "a new record, once saved" do
      let(:image) { Image.new }
      before do
        image.generic_files = [generic_file1, generic_file2]
        image.save
      end

      it "has persisted the association" do
        expect(image.reload.generic_files).to eq [generic_file1, generic_file2]
      end
      it "should be able to delete" do
        image.generic_files = [generic_file1]
        expect(reloaded.generic_files).to eq [generic_file1]
        expect(reloaded.ordered_generic_files).to eq [generic_file1]
      end
      it "should be able to be emptied" do
        image.generic_files = []
        image.save!
        expect(reloaded.generic_files).to eq []
        expect(reloaded.ordered_generic_files).to eq []
      end
      it "should be able to delete a node in the middle" do
        image.generic_files << generic_file3
        image.save
        image.generic_files = [ generic_file2, generic_file3 ]
        expect(image.ordered_generic_files).to eq [generic_file2, generic_file3]
        expect(reloaded.generic_files).to eq [generic_file2, generic_file3]
        expect(reloaded.ordered_generic_files).to eq [generic_file2, generic_file3]
      end

      it "has a first element" do
        expect(reloaded.generic_files.first).to eq generic_file1
      end
    end

    describe "aggregated_by" do
      let(:image) { Image.new }
      before do
        proxy = instance_double(ActiveFedora::Aggregation::Proxy, container: image, target: generic_file1)
        # If I ask the proxy for everything where proxyFor is the file, it
        # WILL return everything it's a proxyFor for. AF guaruntees it.
        allow(ActiveFedora::Aggregation::Proxy).to receive(:where).with(proxyFor_ssim: generic_file1.id).and_return([proxy])
      end

      context "an element aggregated by one record" do
        subject { generic_file1 }
        it "can find the record that contains it" do
          expect(subject.aggregated_by).to eq [image]
        end
      end

      context "an element aggregated by multiple records" do
        let(:image2) { Image.new }
        before do
          proxy = instance_double(ActiveFedora::Aggregation::Proxy, container: image2, target: generic_file2)
          proxy2 = instance_double(ActiveFedora::Aggregation::Proxy, container: image, target: generic_file2)
          allow(generic_file1.send(:proxy_class)).to receive(:where).with(proxyFor_ssim: generic_file2.id).and_return([proxy, proxy2])
        end
        subject { generic_file2 }
        it "can find all of the records that contain it" do
          expect(subject.aggregated_by).to contain_exactly(image2,image)
        end
      end
    end

    context "a persisted record" do
      let(:image) { Image.create }
      before do
        image.generic_files = [generic_file2, generic_file1]
        image.save
      end

      describe "the association" do
        subject { reloaded.generic_files }
        it { is_expected.to eq [generic_file2, generic_file1] }

        it "returns an updated array of generic_files" do
          current_generic_files = image.generic_files.to_a
          new_generic_files = current_generic_files + [generic_file3]
          image.generic_files = new_generic_files
          expect(image.generic_files).to eq [generic_file2, generic_file1, generic_file3]
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

      describe "the proxies" do
        let(:object) { RDF::URI.new(generic_file1.uri) }
        let(:selector) { { predicate: RDF::Vocab::ORE.proxyFor, object: object } }
        let(:proxy_class) { ActiveFedora::Aggregation::Proxy }
        let(:first_proxy) { proxy_class.all.find { |p| p.resource.query(selector).any? } }
        let(:query_result) { first_proxy.resource.query(predicate: RDF::Vocab::ORE.proxyIn).first }
        subject { query_result.object.to_s }

        it "has proxyIn" do
          expect(subject).to eq image.uri
        end
      end

      describe "#ordered_*" do
        it "should return an ordered array" do
          expect(reloaded.ordered_generic_files).to eq [generic_file2, generic_file1]
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
