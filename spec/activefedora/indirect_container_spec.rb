require 'spec_helper'

RSpec.describe ActiveFedora::Aggregation::IndirectContainer do
  subject { described_class.new(id) }
  let(:id) { nil }

  describe "#validations" do
    before do
      subject.membership_resource = ["Test"]
      subject.member_relation = ["Test"]
      subject.inserted_content_relation = ["Test"]
    end
    it "should be valid by default" do
      expect(subject).to be_valid
    end
    context "when there's no membership_resource" do
      it "should be invalid" do
        subject.membership_resource = []

        expect(subject).not_to be_valid
      end
    end
    context "when there's no member_relation" do
      it "should be invalid" do
        subject.member_relation = []
        
        expect(subject).not_to be_valid
      end
    end
    context "when there's no inserted_content_relation" do
      it "should be invalid" do
        subject.inserted_content_relation = []

        expect(subject).not_to be_valid
      end
    end

  end
  describe "#type" do
    it "should be an LDP Indirect Container" do
      expect(subject.resource.query(:predicate => RDF.type).to_a.first.object).to eq ::RDF::Vocab::LDP.IndirectContainer
    end
  end

  #TODO Make a custom matcher
  it "should have a membership_resource" do
    expect(described_class.properties["membership_resource"].predicate).to eq ::RDF::Vocab::LDP.membershipResource
  end

  it "should have a member_relation" do
    expect(described_class.properties["member_relation"].predicate).to eq ::RDF::Vocab::LDP.hasMemberRelation
  end
  
  it "should have an inserted_content_relation" do
    expect(described_class.properties["inserted_content_relation"].predicate).to eq ::RDF::Vocab::LDP.insertedContentRelation
  end

  describe "#contained" do
    context "when there are contained nodes" do
      it "should return them" do
        subject.save
        child = ActiveFedora::Base.new("#{subject.id}/#{SecureRandom.uuid}")
        child.save
        reloaded = described_class.find(subject.id)

        expect(reloaded.contained).to eq [child]
      end
    end
  end

  describe "#contained=" do
    it "should raise a NoMethodError" do
      expect{subject.contained=([])}.to raise_error NoMethodError
    end
  end

end
