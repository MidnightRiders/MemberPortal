require "rails_helper"

RSpec.describe DiscussionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/discussions").to route_to("discussions#index")
    end

    it "routes to #new" do
      expect(:get => "/discussions/new").to route_to("discussions#new")
    end

    it "routes to #show" do
      expect(:get => "/discussions/1").to route_to("discussions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/discussions/1/edit").to route_to("discussions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/discussions").to route_to("discussions#create")
    end

    it "routes to #update" do
      expect(:put => "/discussions/1").to route_to("discussions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/discussions/1").to route_to("discussions#destroy", :id => "1")
    end

  end
end
