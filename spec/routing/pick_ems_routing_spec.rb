require "spec_helper"

describe PickEmsController do
  describe "routing" do

    it "routes to #index" do
      get("/pick_ems").should route_to("pick_ems#index")
    end

    it "routes to #new" do
      get("/pick_ems/new").should route_to("pick_ems#new")
    end

    it "routes to #show" do
      get("/pick_ems/1").should route_to("pick_ems#show", :id => "1")
    end

    it "routes to #edit" do
      get("/pick_ems/1/edit").should route_to("pick_ems#edit", :id => "1")
    end

    it "routes to #create" do
      post("/pick_ems").should route_to("pick_ems#create")
    end

    it "routes to #update" do
      put("/pick_ems/1").should route_to("pick_ems#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/pick_ems/1").should route_to("pick_ems#destroy", :id => "1")
    end

  end
end
