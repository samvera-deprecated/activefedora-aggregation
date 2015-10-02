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
end
