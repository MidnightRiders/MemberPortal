require "spec_helper"

describe MotMsController do
  describe "routing" do

    it "routes to #index" do
      get("/mot_ms").should route_to("mot_ms#index")
    end

    it "routes to #new" do
      get("/mot_ms/new").should route_to("mot_ms#new")
    end

    it "routes to #show" do
      get("/mot_ms/1").should route_to("mot_ms#show", :id => "1")
    end

    it "routes to #edit" do
      get("/mot_ms/1/edit").should route_to("mot_ms#edit", :id => "1")
    end

    it "routes to #create" do
      post("/mot_ms").should route_to("mot_ms#create")
    end

    it "routes to #update" do
      put("/mot_ms/1").should route_to("mot_ms#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/mot_ms/1").should route_to("mot_ms#destroy", :id => "1")
    end

  end
end
