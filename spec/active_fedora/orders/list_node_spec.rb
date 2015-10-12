require 'spec_helper'

RSpec.describe ActiveFedora::Orders::ListNode do
  subject { described_class.new(node_cache, rdf_subject, graph) }
  let(:node_cache) { {} }
  let(:rdf_subject) { RDF::URI("#bla") }
  let(:graph) { RDF::Graph.new }
  
  describe "#target" do
    context "when a target is set" do
      it "returns it" do
        member = instance_double("member")
        subject.target = member
        expect(subject.target).to eq member
      end
    end
    context "when no target is set" do
      context "and it's not in the graph" do
        it "returns nil" do
          expect(subject.target).to eq nil
        end
      end
      context "and it's set in the graph" do
        before do
          class Member < ActiveFedora::Base
          end
        end
        after do
          Object.send(:remove_const, :Member)
        end
        it "returns it" do
          member = Member.create
          graph << [rdf_subject, RDF::Vocab::ORE.proxyFor, member.resource.rdf_subject]
          expect(subject.target).to eq member
        end
        context "and it doesn't exist" do
          it "returns an AT::Resource" do
            member = Member.new("testing")
            graph << [rdf_subject, RDF::Vocab::ORE.proxyFor, member.resource.rdf_subject]
            expect(subject.target.rdf_subject).to eq member.uri
          end
        end
      end
    end
  end

  describe "#target_id" do
    context "when a target is set" do
      it "returns its id" do
        member = instance_double("member", id: "member1")
        subject.target = member
        expect(subject.target_id).to eq "member1"
      end
    end
    context "when a target is from the graph" do
      before do
        class Member < ActiveFedora::Base
        end
      end
      after do
        Object.send(:remove_const, :Member)
      end
      context "and it's cached but missing" do
        it "works" do
          member = Member.create
          graph << [rdf_subject, RDF::Vocab::ORE.proxyFor, member.resource.rdf_subject]
          allow(ActiveFedora::Base).to receive(:from_uri).and_return(ActiveTriples::Resource.new(member.resource.rdf_subject))
          subject.target

          expect(subject.target_id).to eq member.id
        end
      end
      it "doesn't re-ify the target" do
        member = Member.create
        graph << [rdf_subject, RDF::Vocab::ORE.proxyFor, member.resource.rdf_subject]
        allow(ActiveFedora::Base).to receive(:from_uri).and_call_original

        expect(subject.target_id).to eq member.id
        expect(ActiveFedora::Base).not_to have_received(:from_uri)
      end
    end
  end
end
