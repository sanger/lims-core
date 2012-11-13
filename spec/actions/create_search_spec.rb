# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

#Model requirements
require 'lims/core/actions/create_search'
require 'lims/core/persistence/search'
require 'lims/core/laboratory/plate'

module Lims::Core
  module Actions

    shared_examples_for "creating a search" do
      include_context "create object"
      it_behaves_like "an action"
      it "create a search object" do
        result = subject.call
        result.should be_a Hash

        search = result[:search]
        search.should be_a Persistence::Search
        search.model.should == model
        search.filter.criteria.should == criteria
      end
    end

    describe CreateSearch do
      context "valid calling context" do

        before do
          Lims::Core::Persistence::Session.any_instance.tap do |session|
            session.stub(:search) {
              mock(:search).tap do |s|
                s.stub(:[]) 
              end
            }
          end
        end

        include_context("for application",  "Test search creation")
        let(:store) { Persistence::Store.new() }
        let(:model_name) { "plate" }
        let(:criteria) {{ :id => 1 }}

        subject {  CreateSearch.new(:store => store, :user => user, :application => application)  do |a,s|
          a.model = model_name
          a.criteria = criteria
        end
        }
   
        context "valid" do
          let(:model) { Laboratory::Plate }
          it_behaves_like "creating a search"
        end

        context "invalid" do
          context "criteria not matching column" do
            let(:model_name) { "plate" }
            let(:model) { Laboratory::Plate }
            let(:criteria)  { { :dummy_attribute => :test } } 

            pending "needs implementatio" do
              it "should raise an error" do
                subject.call.should == false
              end
            end
          end
        end
      end
    end
  end
end

