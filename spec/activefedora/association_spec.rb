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

    describe "#delete" do
      let(:image) { Image.new }
      let(:file) { GenericFile.new }
      context "with an unrelated object" do
        it "should return an empty set" do
          expect(image.generic_files.delete(file)).to eq []
        end
      end
      context "with a contained object" do
        it "should return the deleted objects" do
          g = GenericFile.new
          image.generic_files += [g]

          expect(image.generic_files.delete(g, file)).to eq [g]
        end
      end
    end

    describe "#concat" do
      let(:image) { Image.new }
      context "when the association is empty" do
        before do
          image.generic_files << generic_file1 << generic_file2
        end

        subject { image.generic_files }

        it { is_expected.to eq [generic_file1, generic_file2] }

        context "and persisted" do
          before do
            image.save
            image.reload.generic_files
          end

          it { is_expected.to eq [generic_file1, generic_file2] }
        end
      end

      context "when the association contains records" do
        before do
          image.generic_files = [generic_file1]
          image.generic_files << generic_file2
        end

        subject { image.generic_files }

        it { is_expected.to eq [generic_file1, generic_file2] }

        context "and persisted" do
          before do
            image.save
            image.reload.generic_files
          end

          it { is_expected.to eq [generic_file1, generic_file2] }
        end
      end
    end

    describe "#ids_reader" do
      let(:image) { Image.new }
      context "with saved members" do
        before do
          image.generic_files = [generic_file1, generic_file2]
          image.save
        end

        subject { image.reload.generic_file_ids }
        it { is_expected.to eq [generic_file1.id, generic_file2.id] }
      end

      context "without members" do
        before do
          image.save
        end

        subject { image.reload.generic_file_ids }
        it { is_expected.to eq [] }
      end
    end

    context "a new record, once saved" do
      let(:image) { Image.new }
      before do
        image.generic_files = [generic_file1, generic_file2]
        image.save
      end

      it "has persisted the association" do
        expect(image.reload.generic_files).to eq [generic_file1, generic_file2]
      end

      it "is able to be replaced" do
        image.generic_files = [generic_file1]
        image.reload
        expect(image.generic_files).to eq [generic_file1]
        expect(image.ordered_generic_files).to eq [generic_file1]
      end

      it "is able to be emptied" do
        image.generic_files = []
        image.save!
        image.reload
        expect(image.generic_files).to eq []
        expect(image.ordered_generic_files).to eq []
      end

      it "is able to replace a node in the middle" do
        image.generic_files << generic_file3
        image.save
        image.generic_files = [ generic_file2, generic_file3 ]
        expect(image.ordered_generic_files).to eq [generic_file2, generic_file3]
        image.reload
        expect(image.generic_files).to eq [generic_file2, generic_file3]
        expect(image.ordered_generic_files).to eq [generic_file2, generic_file3]
      end

      it "has a first element" do
        expect(image.reload.generic_files.first).to eq generic_file1
      end
    end

    describe "aggregated_by" do
      let(:image) { Image.new }
      before do
        ActiveFedora::Aggregation::Proxy.create(container: image, target: generic_file1)
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
          # If I ask the proxy for everything where proxyFor is the file, it
          # WILL return everything it's a proxyFor for. AF guaruntees it.
          proxy = instance_double(ActiveFedora::Aggregation::Proxy, container: image2)
          proxy2 = instance_double(ActiveFedora::Aggregation::Proxy, container: image)
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
        subject { image.reload.generic_files }
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
          expect(image.reload.resource.query(predicate: ::RDF::Vocab::ORE.aggregates).count).to eq 2
        end

        it "associates directly to aggregated resource" do
          expect(image.reload.resource.query(predicate: ::RDF::Vocab::ORE.aggregates).to_a.first.object).to eq generic_file2.resource.rdf_subject
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
          expect(image.reload.ordered_generic_files).to eq [generic_file2, generic_file1]
        end
      end

      describe "#head" do
        it "returns the first proxy" do
          expect(image.reload.head).to be_kind_of ActiveFedora::Aggregation::Proxy
        end
      end
      describe "#head_id" do
        it "returns the first proxy" do
          expect(image.reload.head_id).to be_kind_of String
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

    describe "the association" do
      subject { image.reload.files }
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

    describe "the association" do
      subject { image.reload.files }
      it { is_expected.to eq [generic_file2, generic_file1] }
    end
  end

  context "with a type validation" do
    let(:image) { Image.new }
    let(:parent) { Image.new }
    before do
      class TypeValidator
        def self.validate!(record)
        end
      end
      class Image < ActiveFedora::Base
        aggregates :files, type_validator: TypeValidator
      end
      allow(TypeValidator).to receive(:validate!).with(image).and_raise ActiveFedora::AssociationTypeMismatch
    end
    after do
      Object.send(:remove_const, :Image)
      Object.send(:remove_const, :TypeValidator)
    end

    context "when an invalid item is passed" do
      it "should raise an error" do
        expect{ parent.files = [image] }.to raise_error ActiveFedora::AssociationTypeMismatch
      end
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
      image.save!
    end

    describe "the association" do
      subject { image.reload.foos }
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

    describe "the association" do
      subject { image.reload.generic_files }
      it { is_expected.to eq [generic_file2, generic_file1] }

      it "has a first element" do
        expect(subject.first).to eq generic_file2
      end

      it "uses the specified predicate" do
        query_result = image.reload.resource.query(predicate: predicate)
        expect(query_result.count).to eq 2
      end

      it { is_expected.to eq [generic_file2, generic_file1] }
    end
  end
end
